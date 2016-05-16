class ScreenTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model
  include Softwear::Auth::BelongsToUser

  PRINT_TYPES = [
    "spot", "process", "simulated process"
  ]

  tracked only: [:transition]

  belongs_to_user_called :assigned_to
  belongs_to :order
  has_many :assigned_screens, dependent: :destroy
  has_many :screens, through: :assigned_screens
  has_many :imprints
  has_many :machines, through: :imprints
  has_many :jobs, through: :imprints
  has_many :screen_requests, -> { order(ink: :asc) },  dependent: :destroy

  validates :order, presence: true
  validates :print_type, inclusion: { in: PRINT_TYPES }, unless: -> { self.print_type.blank? }
  
  accepts_nested_attributes_for :assigned_screens, allow_destroy: true
  accepts_nested_attributes_for :screen_requests, allow_destroy: true
 
  searchable do 
    text :artwork_location, :job_names, :imprint_names, :id
    integer :assigned_to_id, :signed_off_by_id
    boolean :new_separation
    boolean :fba
  end

  train_type :pre_production
  train initial: :pending_sep_request, final: :complete do
    
    success_event :sep_request_complete do
      transition :pending_sep_request => :pending_sep_assignment, if: -> (s) { s.new_separation? && s.proof_request_data_complete? && s.assigned_to_id.blank? }
      transition :pending_sep_request => :pending_separation, if: -> (s) { s.new_separation? && s.proof_request_data_complete? && !s.assigned_to_id.blank? }
      transition :pending_sep_request => :pending_approval, if: -> (s) { !s.new_separation? && s.proof_request_data_complete? }
    end

    success_event :assigned,
        params: { assigned_to_id: -> { [""] + User.all.map{|x| [x.full_name, x.id] } } } do
      transition :pending_sep_assignment => :pending_separation
    end

    success_event :separated do 
      transition :pending_separation => :pending_approval
    end

    success_event :approved,
        params: { signed_off_by_id: -> { [""] + User.all.map{|x| [x.full_name, x.id] } } } do
      transition :pending_approval => :pending_screens
    end

    success_event :screens_assigned do 
      transition :pending_screens => :complete, if: -> (s) { s.all_screens_assigned? }
    end
    
    delay_event :bad_separation, 
      public_activity: { reason: :text_field } do 
      transition [:pending_screens, :complete] => :pending_separation
    end

    delay_event :bad_burnout do 
      transition :complete => :pending_screens
    end

    state :pending_sep_request, type: :success
    state :pending_separation, type: :success
    state :pending_approval, type: :success
    state :pending_screens, type: :success
    state :complete, type: :success
  end

  def proof_request_data_complete?
    return false if order.blank?
    return false if imprints.empty?
    return false if due_at.blank?
    return false if artwork_location.blank?
    return false if print_type.blank?
    return true
  end

  def lpi
    super.blank? ? '45' : super
  end

  def unique_jobs
    unique_jobs = []
    job_ids = self.imprints.flat_map{ |i| i.job_id }.uniq

    job_ids.each do |j_id|
      unique_jobs << Job.find(j_id)
    end

    unique_jobs
  end

  def self.order_id_and_name(train)
    crm = train.order.crm
    return "CRM##{crm.id} - #{crm.name}"
  end

  def screen_inks
    screen_requests.group(:ink).map(&:ink)
  end

  def all_screens_assigned?
    screen_requests.count > 0 && screen_inks.count == assigned_screens.count
  end

  def imprint_count 
    imprints.sum(:count)
  end

  def has_multiple_imprints?
    imprints.count > 1
  end

  def has_different_jobs?
    imprints.map{ |i| i.softwear_crm_id }.uniq.count > 1
  end

  def machines
    imprints.map{|x| x.machine.name rescue nil }.uniq.compact
  end

  private

  def imprint_names
    imprints.pluck(:name).join(' ')
  end

  def job_names
    jobs.pluck(:name).join(' ')
  end

  def earliest_scheduled_date
    imprints.pluck(:scheduled_at).compact.min
  end

  def latest_scheduled_date
    imprints.pluck(:scheduled_at).compact.max
  end
end

class ScreenTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model
  
  PRINT_TYPES = [
    "spot", "process", "simulated process"
  ]

  tracked only: [:transition]

  belongs_to :assigned_to, foreign_key: :assigned_to_id, class_name: 'User'  
  belongs_to :order
  has_many :assigned_screens
  has_many :screens, through: :assigned_screens
  has_many :imprints
  has_many :machines, through: :imprints
  has_many :jobs, through: :imprints
  has_many :screen_requests

  validates :order, presence: true
  validates :print_type, inclusion: { in: PRINT_TYPES }, unless: -> { self.print_type.blank? }
  
  train_type :pre_production
  train initial: :pending_sep_request, final: :complete do
    
    success_event :sep_request_complete do
      transition :pending_sep_request => :pending_sep_assignment, if: -> (s) { s.new_separation? && s.proof_request_data_complete? }
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
    return false if garment_material.blank?
    return false if garment_weight.blank?
    return false if artwork_location.blank?
    return false if print_type.blank?
    return true
  end

  def screen_inks
    screen_requests.group(:ink).map(&:ink)
  end

  def all_screens_assigned?
    screen_inks.count == assigned_screens.count
  end

  def fba?
    order.fba?
  end

  def imprint_count 
    imprints.sum(:count)
  end
  
end

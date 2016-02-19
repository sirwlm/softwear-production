class DigitizationTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train
  include Deadlines
  include Softwear::Auth::BelongsToUser

  tracked only: [:transition]

  belongs_to :order
  has_many :imprints
  has_many :jobs, through: :imprints
  belongs_to_user_called :approved_by
  belongs_to_user_called :digitization_assigned_to

  searchable do 
    text :artwork_location
    integer :assigned_to_id, :signed_off_by_id
    boolean :fba
  end
  
  train_type :pre_production
  train initial: :pending_digital_artwork, final: :complete do
    success_event :artwork_sent, params: { artwork_location: :text_field } do
      transition :pending_digital_artwork => :pending_digitization
    end
    success_event :artwork_sent do
      transition :pending_digital_artwork => :pending_guides
    end

    success_event :sent_to_third_party, params: { third_party_name: :text_field } do
      transition :pending_digitization => :pending_digitized_file_from_third_party
    end
    success_event :assigned_to_employee,
        params: { digitization_assigned_to_id: -> { User.pluck(:email, :id) } } do
      transition :pending_digitization => :pending_digitized_file_from_employee
    end

    success_event :approved, params: { approved_by_id: -> { User.pluck(:email, :id) } } do
      transition :pending_digitized_file_from_employee => :pending_guides
    end
    success_event :received_from_third_party do
      transition :pending_digitized_file_from_third_party => :pending_guides
    end

    success_event :guides_made_and_sent_to_machine do
      transition :pending_guides => :complete
    end
  end
  
  def fba?
    order.try(:fba?)
  end
  
  def assigned_to_id; return nil; end
  alias_method :due_at, :production_deadline
  
  private
  
  def order_name
    order.try(:name)
  end
end

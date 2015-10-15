class DigitizationTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  tracked only: [:transition]

  belongs_to :order
  has_many :imprints
  has_many :jobs, through: :imprints
  belongs_to :approved_by, class_name: User
  belongs_to :digitization_assigned_to, class_name: User

  searchable do 
    text :human_state_name, :due_at, :artwork_location, :order_name
    string :state
    integer :assigned_to_id, :signed_off_by_id
    time :due_at
    time :created_at
    string :class_name do 
      self.class.name
    end
    boolean :complete do 
      self.complete?
    end
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
    order.fba?
  end
  
  def assigned_to_id; return nil; end
  def due_at; return order.deadline - 2.days; end
  
  private
  
  def order_name
    order.try(:name)
  end
end

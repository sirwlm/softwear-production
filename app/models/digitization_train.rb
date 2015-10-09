class DigitizationTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  tracked only: [:transition]

  belongs_to :order
  belongs_to :approved_by, class_name: User
  belongs_to :digitization_assigned_to, class_name: User

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
end

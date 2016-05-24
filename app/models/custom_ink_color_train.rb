class CustomInkColorTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train

  tracked only: [:transition]

  belongs_to :order

  train_type :pre_production
  train initial: :not_yet_requested, final: :mixed do
    success_event :ink_requested do
      transition :not_yet_requested => :requested
    end

    success_event :confirm_supplies,
        public_activity: { user_id: -> { User.all.map { |u| [u.full_name, u.id] } } } do
      transition :requested => :supplies_confirmed
    end

    success_event :ink_ready do
      transition :supplies_confirmed => :ready
    end

    success_event :ink_mixed,
        public_activity: { user_id: -> { User.all.map { |u| [u.full_name, u.id] } } } do
      transition :ready => :mixed
    end
  end
end

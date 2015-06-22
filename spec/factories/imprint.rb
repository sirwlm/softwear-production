FactoryGirl.define do
  factory :blank_imprint, class: Imprint do
    name 'An Imprint'
    description 'An Imprint Description'
    state 'pending_approval'

    factory :imprint do
      scheduled_at Time.now
      sequence(:estimated_time) { |n| n }
      machine { |imprint| imprint.association(:machine) }
    end
  end
end

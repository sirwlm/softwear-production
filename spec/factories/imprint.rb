FactoryGirl.define do
  factory :blank_imprint, class: Imprint do
    factory :imprint do
      scheduled_at Time.now
      sequence(:estimated_time) { |n| n }
      machine { |imprint| imprint.association(:machine) }
    end
  end
end
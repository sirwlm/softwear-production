FactoryGirl.define do
  factory :maintenance do
    sequence(:name) { |n| "Maintenance #{n}" }
    sequence(:description) { |n| "Description of maintenance #{n}" }
  end
end

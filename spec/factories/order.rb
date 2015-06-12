FactoryGirl.define do
  factory :order do
    name 'whatever'
    deadline 5.days.from_now
  end
end

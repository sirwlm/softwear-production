FactoryGirl.define do
  factory :order do
    name 'whatever'
    deadline 5.days.from_now
    jobs { create_list(:job, 1) }
  end
end

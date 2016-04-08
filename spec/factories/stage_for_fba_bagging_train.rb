FactoryGirl.define do
  factory :stage_for_fba_bagging_train do
    location "Test Location"
    order { |o| o.association(:order) }
  end
end

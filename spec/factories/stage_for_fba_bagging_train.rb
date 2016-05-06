FactoryGirl.define do
  factory :stage_for_fba_bagging_train do
    inventory_location "Test Location"
    order { |o| o.association(:order) }
  end
end

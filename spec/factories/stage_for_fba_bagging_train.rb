FactoryGirl.define do
  factory :stage_for_fba_bagging_train do
    order { |o| o.association(:order) }
  end
end

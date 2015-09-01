FactoryGirl.define do

  factory :fba_bagging_train do
    order { |t| t.association(:order) }  
  end

end

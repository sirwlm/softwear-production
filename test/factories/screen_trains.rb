FactoryGirl.define do
  factory :screen_train do
    order {|t| t.association :order }
    print_type  'spot'  
    new_separation  true 
  
  end
end

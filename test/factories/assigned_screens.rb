FactoryGirl.define do
  factory :assigned_screen do
    screen {|t| t.association :screen }   
  end

end

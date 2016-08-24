FactoryGirl.define do
  begin
    factory :imprintable_train do
      expected_arrival_date Date.today
      location "Here"
    end
  rescue FactoryGirl::DuplicateDefinitionError
  end
end

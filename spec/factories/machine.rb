FactoryGirl.define do
  factory :blank_machine, class: Machine do

    factory :machine do
      sequence(:name) { |n| "machine_#{n}" }
    end

    after(:create) { |machine| create(:imprint, machine_id: machine.id) }
  end
end

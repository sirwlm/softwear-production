FactoryGirl.define do
  factory :blank_machine, class: Machine do

    factory :machine do
      sequence(:name) { |n| "machine_#{n}" }
      color { "rgb(#{Random.rand(255)}, #{Random.rand(255)}, #{Random.rand(255)})" }

      factory :machine_with_imprint do
        after(:create) { |machine| create(:imprint, machine_id: machine.id) }
      end
    end
  end
end

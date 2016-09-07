FactoryGirl.define do
  factory :blank_user, class: User do

    factory :user do
      sequence(:id) { |n| n + 1 }
      first_name 'Test_First'
      sequence(:last_name) { |n| "Test_Last_#{n}" }
      sequence(:email) { |n| "user_email_#{n}@hotmail.com" }
      default_view "Mobile"
      roles []

      initialize_with do
        new(
          id:         id,
          first_name: first_name,
          last_name:  last_name,
          email:      email,
          roles: roles
        )
      end

      factory :admin do
        first_name 'Uber'
        last_name 'Mensch'
        sequence(:email) { |n| "idol_#{n}@god.com"}
        roles ['admin', 'manager']
      end

      before(:create) do |u|
        u.instance_variable_set(:@persisted, true)
      end

      after(:create) do |u|
        spec_users << u if try(:spec_users)
      end
    end
  end
end

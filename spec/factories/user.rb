FactoryGirl.define do
  factory :blank_user, class: User do

    factory :user do
      first_name 'Test'
      last_name 'User'
      sequence(:email) { |n| "email_#{n}" }
      password '123456789'
    end
  end
end

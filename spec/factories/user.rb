FactoryGirl.define do
  factory :blank_user, class: User do

    factory :user do
      first_name 'Test'
      last_name 'User'
      sequence(:email) { |n| "email_#{n}@gmail.com" }
      password '123456789'
    end

    factory :admin do
      first_name 'Uber'
      last_name 'Mensch'
      sequence(:email) { |n| "idol_#{n}@god.com"}
      password '2_1337_4_u'
      admin true
    end

    after(:create) { |u| u.confirm! }
  end
end

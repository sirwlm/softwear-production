FactoryGirl.define do
  sequence :name do |n|
    ['Test Order', 'Custom Print Order', 'Custom T-shirt Order',
      'Crap Order', 'Expensive Order'][n%5]
  end

  factory :order, class: Crm::Order do
    name { generate :name }
    sequence(:email) { |n| "order_email_#{n}@gmail.com" }
    company 'Test Company'
    in_hand_by Time.now + 1.month
  end
end
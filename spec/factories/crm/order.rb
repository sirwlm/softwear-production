FactoryGirl.define do
  sequence :name do |n|
    ['Test Order', 'Custom Print Order', 'Custom T-shirt Order',
      'Some Crap', 'High Quality Hip Threads'][n%5]
  end

  factory :crm_order, class: Crm::Order do
    name { generate :name }
    sequence(:email) { |n| "order_email_#{n}@gmail.com" }
    company 'Test Company'
    in_hand_by Time.now + 1.month

    factory :crm_order_with_proofs do
      proofs { [create(:crm_proof)] }
    end
  end
end

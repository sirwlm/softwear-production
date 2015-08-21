FactoryGirl.define do
  sequence :imprint_name do |n|
    ['3 Color Back', '2 Color Front', '1 Color Left Chest',
      'Bluh', 'Blah'][n%5]
  end

  factory :crm_imprint, class: Crm::Imprint do
    name { generate :imprint_name }
    proofs []

    factory :crm_imprint_with_proofs do
      proofs { [create(:crm_proof)] }
    end
  end
end

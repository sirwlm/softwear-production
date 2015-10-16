FactoryGirl.define do
  factory :crm_proof, class: Crm::Proof do
    status 'Pending'
    approve_by '06/05/2014 03:07 PM'
    mockup_paths []
    artworks []
  end
end

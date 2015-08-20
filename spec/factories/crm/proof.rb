FactoryGirl.define do
  factory :crm_proof, class: Crm::Proof do
    status 'Pending'
    approve_by '06/05/2014 03:07 PM'
    artwork_paths []
    artwork_thumbnail_paths []
    mockup_paths []
    mockup_thumbnail_paths []
  end
end

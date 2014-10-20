FactoryGirl.define do
  factory :crm_job, class: Crm::Job do
    sequence(:name) { |s| "Test Job #{s}" }
    description 'Test job description!'
    order { |o| o.association(:order) }
  end
end
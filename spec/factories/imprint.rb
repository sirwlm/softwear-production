FactoryGirl.define do
  factory :imprint do
    scheduled_at Time.now
    estimated_time 158

    before(:create) do |imprint|
      imprint.machine_id = create(:machine).id
    end
  end
end
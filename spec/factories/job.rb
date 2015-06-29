FactoryGirl.define do
  factory :job do
    name 'test job'
    imprints { [create(:imprint)] }
  end
end


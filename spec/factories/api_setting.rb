FactoryGirl.define do
  factory :api_setting do
    endpoint 'http://crm.com/api'
    slug 'api'
    auth_token 'asfjipwaej39i'
    homepage 'http://crm.com/'

    factory :crm_setting do
      slug 'crm'
    end
  end
end

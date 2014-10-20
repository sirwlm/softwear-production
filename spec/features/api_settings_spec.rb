require 'spec_helper'

feature 'API Settings Management', api_spec: true, story_201: true do
  context 'CRM Settings' do
    context 'when a crm settings record does not exist' do
      scenario 'A user can create one', js: true do
        visit root_path
        click_link 'Admin'

        click_link 'Crm Api Settings'

        fill_in 'Endpoint', with: 'http://totally-a-real-endpoint.com/api'
        fill_in 'Auth token', with: 'awejiopjf3498fjqwa'
        fill_in 'Homepage', with: 'http://softwearcrm.com/'

        click_button 'Create Api setting'

        expect(page).to have_content 'Hooray!'
        crm_setting = ApiSetting.find_by(slug: 'crm')

        expect(crm_setting).to_not be_nil
        expect(crm_setting.endpoint).to eq 'http://totally-a-real-endpoint.com/api'
        expect(crm_setting.auth_token).to eq 'awejiopjf3498fjqwa'
        expect(crm_setting.homepage).to eq 'http://softwearcrm.com/'
      end
    end
  end
end

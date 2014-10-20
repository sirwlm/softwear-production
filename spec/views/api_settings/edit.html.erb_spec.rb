require 'spec_helper'

describe 'api_settings/edit.html.erb', api_spec: true, story_201: true do
  let!(:crm_setting) { build_stubbed :crm_setting }

  it 'has fields for endpoint, auth_token and homepage' do
    assign(:api_setting, crm_setting)
    render

    expect(rendered).to have_css 'input[name="api_setting[endpoint]"]'
    expect(rendered).to have_css 'input[name="api_setting[auth_token]"]'
    expect(rendered).to have_css 'input[name="api_setting[homepage]"]'
  end
end

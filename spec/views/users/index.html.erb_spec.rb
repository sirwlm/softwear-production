require 'spec_helper'

describe 'users/index.html.erb', user_spec: true, story_116: true do
  include_context 'devise_view_setup'

  let!(:user) { create(:user) }

  before(:each) do
    assign(:users, [user])
    sign_in user
    render
  end

  it 'displays a page header' do
    expect(rendered).to have_content('View and Edit registered Users')
    expect(rendered).to have_css('a[href="/users/new"]')
  end
end

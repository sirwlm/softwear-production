require 'spec_helper'

describe 'users/new.html.erb', user_spec: true, story_116: true do
  include_context 'devise_view_setup'

  let!(:user) { create(:user) }

  before(:each) do
    assign(:user, user)
    sign_in user
    render
  end

  it 'displays a page header' do
    expect(rendered).to have_content('New User form')
  end
end

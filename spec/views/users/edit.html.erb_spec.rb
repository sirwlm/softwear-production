require 'spec_helper'

describe 'users/edit.html.erb', user_spec: true, story_116: true do
  include_context 'devise_view_setup'
  include_context 'signed_in_as_user'

  let!(:user) { create(:user) }

  before(:each) do
    assign(:user, user)
    render
  end

  it 'displays a page header' do
    expect(rendered).to have_content("Edit User #{user.full_name}")
  end
end

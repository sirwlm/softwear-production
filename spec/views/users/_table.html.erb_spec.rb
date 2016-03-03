require 'spec_helper'

describe 'users/_table.html.erb', user_spec: true, story_116: true do
  include_context 'devise_view_setup'
  let!(:user) { build_stubbed(:user) }

  before(:each) { render 'users/table.html.erb', users: [user]}

  it 'has a table with the appropriate headers' do
    expect(rendered).to have_content('Name')
    expect(rendered).to have_content('Email')
    expect(rendered).to have_content('Admin?')
  end

  it 'has a table body with user information in it' do
    expect(rendered).to have_content user.full_name
    expect(rendered).to have_content user.email
    expect(rendered).to have_content human_boolean(user.admin?)
    expect(rendered).to have_css "a[href='/users/#{user.id}/edit']"
    expect(rendered).to have_css "a[href='/users/delete_user/#{user.id}'][data-method='delete']"
  end
end

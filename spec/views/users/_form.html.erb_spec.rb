require 'spec_helper'

describe 'users/_form.html.erb', user_spec: true, story_116: true do
  include_context 'devise_setup'

  let!(:user) { create(:user) }

  context 'when editing a new user' do
    before(:each) { render 'users/form', user: User.new, url: 'users/create_user' }

    it 'has fields for first name, last name, email, password, and password confirmation, and admin' do
      expect(rendered).to have_css('input#user_first_name')
      expect(rendered).to have_css('input#user_last_name')
      expect(rendered).to have_css('input#user_email')
      expect(rendered).to have_css('input#user_admin')
      expect(rendered).to have_css('input#user_password')
      expect(rendered).to have_css('input#user_password_confirmation')
    end
  end

  context 'when editing an existing user' do
    before(:each) { render 'users/form', user: user, url: "users/#{user.id}" }

    it 'has fields for first and last name, email, and admin' do
      expect(rendered).to have_css('input#user_first_name')
      expect(rendered).to have_css('input#user_last_name')
      expect(rendered).to have_css('input#user_email')
      expect(rendered).to have_css('input#user_admin')
    end
  end
end

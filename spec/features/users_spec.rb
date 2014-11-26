require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Users', user_spec: true, js: true, story_115: true do
  given!(:user) { create(:user) }

  context 'with valid credentials' do
    scenario 'a user can log in' do
      visit root_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
      expect(current_path).to eq '/'
    end
  end

  context 'when logged in', new: true do
    background(:each) { login_as user }

    scenario 'a user can see his name on the dashboard' do
      visit root_path
      expect(page).to have_content user.full_name
    end

    scenario 'a user can change his password' do
      # TODO: this is disgusting...
      # I couldn't manage custom flash messages and the default ones weren't firing
      # so I had to resort to using the user's encrypted password
      new_pw = 'NewPassword'
      old_pw = user.encrypted_password

      visit edit_user_registration_path(user)
      fill_in 'Password',              with: new_pw
      fill_in 'Password confirmation', with: new_pw
      fill_in 'Current password',      with: user.password
      click_button 'Update'

      expect(User.find(user.id).encrypted_password).to_not eq(old_pw)
    end

    scenario 'a user can log out' do
      visit root_path
      click_link user.full_name
      click_link 'Log Out'
      expect(current_path).to eq '/users/sign_in'
    end
  end

  scenario 'pending cases', pending: 'different story' do
    scenario 'a user can view a list of users' do
      visit root_path
      unhide_dashboard
      click_link 'Administration'
      wait_for_ajax
      click_link 'Users'
      wait_for_ajax
      expect(page).to have_css "tr#user_#{valid_user.id} > td", text: valid_user.full_name
    end

    scenario "a user can edit another's info" do
      visit users_path
      first('a[title=Edit]').click
      fill_in 'Last name', with: 'Newlast_name'
      click_button 'Update'
      wait_for_ajax
      expect(page).to have_content 'success'
      expect(User.where(last_name: 'Newlast_name')).to exist
    end

    scenario 'a user can create a new user account' do
      visit users_path
      click_link 'Create new user'
      fill_in 'Email', with: 'newguy@example.com'
      fill_in 'First name', with: 'New'
      fill_in 'Last name', with: 'Last'
      select valid_user.store.name, from: 'Store'
      click_button 'Create'
      expect(page).to have_content 'success'
    end

    scenario 'a user can update his freshdesk information' do
      visit edit_user_path valid_user
      fill_in 'Freshdesk Password', with: 'pw4freshdesk'
      fill_in 'Freshdesk Email', with: 'capybara@annarbortees.com'
      click_button 'Update'
      expect(page).to have_content 'success'
    end

    scenario 'a user can lock himself' do
      visit orders_path
      find('a#account-menu').click
      wait_for_ajax
      click_link 'Lock me'
      wait_for_ajax
      expect(current_path).to eq '/users/sign_in'
    end

    scenario 'a user is locked out if he idles for too long' do
      visit orders_path
      wait_for_ajax
      execute_script 'idleTimeoutMs = 1000; idleWarningSec = 5;'
      sleep 0.1
      find('th', text: 'Salesperson').click
      sleep 1.5
      expect(page).to have_css '.modal-body'
      sleep 6
      expect(current_path).to eq new_user_session_path
    end

    scenario 'If a user sees the lock-out warning, he can cancel it by clicking' do
      visit orders_path
      wait_for_ajax
      execute_script 'idleTimeoutMs = 1000; idleWarningSec = 5;'
      sleep 0.1
      find('th', text: 'Salesperson').click
      sleep 1.3
      find('.modal-title').click
      wait_for_ajax
      expect(page).to_not have_css '.modal-body'
    end
  end
end

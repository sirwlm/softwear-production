require 'spec_helper'

feature 'Users', user_spec: true, js: true, story_115: true do
  given!(:admin) { create(:admin) }
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

  context 'when logged in as regular user' do
    include_context 'logged_in_as_user'

    scenario 'a user can see his name on the dashboard' do
      visit root_path
      expect(page).to have_content user.full_name
    end

    scenario 'a user can change his password' do
      new_pw = 'NewPassword'
      visit edit_user_registration_path(user)
      fill_in 'Password',              with: new_pw
      fill_in 'Password confirmation', with: new_pw
      fill_in 'Current password',      with: user.password
      click_button 'Update'
      expect(page).to have_content 'Hooray! Your account has been updated successfully.'
    end

    scenario 'a user can log out' do
      visit root_path
      click_link user.full_name
      click_link 'Log Out'
      expect(current_path).to eq '/users/sign_in'
    end
  end

  context 'when logged in as admin', story_116: true do
    include_context 'logged_in_as_admin'

    scenario 'an admin can view a list of users', story_116: true do
      visit root_path
      click_link 'Admin'
      click_link 'Users'
      expect(page).to have_content 'View and Edit registered Users'
    end

    scenario "an admin can edit a user's info", story_116: true do
      visit users_path
      first('a[data-action="Edit"]').click
      fill_in 'Last name', with: 'Testing'
      click_button 'Update User'
      expect(page).to have_content 'Hooray!'
      expect(User.where(last_name: 'Testing')).to exist
    end

    scenario 'a user can create a new user account' do
      visit users_path
      click_link 'Add a user'
      fill_in 'First name', with: 'New'
      fill_in 'Last name', with: 'Test'
      fill_in 'Email', with: 'newguy@example.com'
      fill_in 'Password', with: '123789456'
      fill_in 'Password confirmation', with: '123789456'
      click_button 'Create User'
      expect(page).to have_content 'Hooray!'
    end
  end
end

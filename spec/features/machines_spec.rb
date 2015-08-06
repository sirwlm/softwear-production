require 'spec_helper'

feature 'Machine Features', js: true, machine_spec: true, story_113: true do
  given!(:machine) { create(:machine) }


  context 'as an administrator' do 
    include_context 'logged_in_as_admin'

    scenario 'A user can view a list of machines' do
      visit root_path
      click_link 'Admin'
      click_link 'Machines'
      expect(page).to have_css('table#machine-table')
    end

    scenario 'A user can edit a machine' do
      visit machines_path
      click_link 'Edit'
      fill_in 'Name', with: 'New Machine Name'
      click_button 'Update Machine'
      sleep 1
      expect(Machine.where(name: 'New Machine Name')).to exist
      expect(page).to have_css('div.alert-success')
    end

    scenario 'A user can destroy a machine' do
      visit machines_path
      click_link 'Destroy'
      sleep 1
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to have_css('div.alert-success')
    end
  end

  context 'as a user' do 
    include_context 'logged_in_as_user'

    scenario 'A user can not view a list of machines' do
      visit machines_path
      expect(page).to have_content "Error! You are not authorized to access this page."
    end

    scenario 'A user can not edit a machine' do
      visit machines_path
      expect(page).not_to have_content "Edit"
    end

    scenario 'A user can not destroy a machine' do
      visit machines_path
      expect(page).not_to have_content "Destroy"
    end

  end
end

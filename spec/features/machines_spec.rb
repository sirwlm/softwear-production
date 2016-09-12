require 'spec_helper'

feature 'Machine Features', js: true, machine_spec: true, story_113: true do
  given!(:machine) { create(:machine) }
  given!(:order) { create(:order_with_print) }

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

    scenario 'A user can not view unscheduled imprints if in "Tablet View"', tablet: true do
      visit machine_path(machine)
      sleep 1
      
      click_link "#{user.full_name}"
      sleep 1
      click_button "View Desktop Version"
      sleep 1

      expect(page).to have_content("Ready to Schedule Imprints")

      click_link "#{user.full_name}"
      sleep 1
      click_button "View Mobile Version"
      sleep 1

      # page shouldn't have this text as it is 'Mobile' view now
      expect(page).to_not have_content("Ready to Schedule Imprints")
    end

    scenario 'A user can not edit a machine' do
      visit machines_path
      expect(page).not_to have_content "Edit"
    end

    scenario 'A user can not destroy a machine' do
      visit machines_path
      expect(page).not_to have_content "Destroy"
    end

    scenario 'A user can see an agenda refresh and see updated information', refresh: true do
      order.imprints.each do |imprint|
        imprint.machine_id = machine.id
        imprint.save
      end
      order.save

      visit machine_agenda_path(machine)
      old_name = order.name
      expect(page).to have_content "#{old_name}"
      new_name = "This is the new name"
      order.name = new_name
      order.save

      sleep 7 
      expect(page).to have_content "#{new_name}"
    end
  end
end

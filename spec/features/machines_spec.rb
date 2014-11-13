require 'spec_helper'

feature 'Machine Features', js: true, machine_spec: true, story_113: true do
  given!(:machine) { create(:machine) }

  scenario 'A user can view a calendar for a machine via show', pending: 'need to figure this out' do
    visit machines_path
    click_link 'Show'
    expect(page).to have_css("div#machine-calendar[data-machine='#{machine.id}']")
  end

  scenario 'A user can view a calendar for a machine via calendar', pending: 'need to figure this out' do
    visit root_path
    click_link 'Calendar'
    click_link "#{machine.name}"
    expect(page).to have_css("div#machine-calendar[data-machine='#{machine.id}']")
  end

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
    expect(Machine.where(name: 'New Machine Name')).to exist
    expect(page).to have_css('div.alert-success')
  end

  scenario 'A user can destroy a machine' do
    visit machines_path
    click_link 'Destroy'
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to have_css('div.alert-success')
  end
end
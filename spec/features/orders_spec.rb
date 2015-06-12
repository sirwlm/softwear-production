require 'spec_helper'

feature 'Orders' do
  given!(:machine) { create(:machine) }

  scenario 'I can create a new order, with jobs and imprints', js: true, story_676: true do
    visit new_order_path
    fill_in 'Name', with: 'Test Order'
    click_button 'Add Job'

    within '.new-job-in-order' do
      fill_in 'Name', with: 'A job'
      click_button 'Add Imprint'
      within '.new-imprint-in-job' do
        fill_in 'Name', with: 'An imprint'
        fill_in 'Description', with: 'Here it is - the imprint'
        select machine.name, from: 'Machine'
        fill_in 'Estimated Time in Hours', with: 3
      end
    end

    click_button 'Create Order'

    expect(page).to have_content 'Successfully created Order'
    expect(Order.where(name: 'Test Order')).to exist
    expect(Job.where(name: 'A job')).to exist
    expect(Imprint.where(name: 'An imprint')).to exist
  end
end

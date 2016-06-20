require 'rails_helper'

feature "Metrics", type: :feature do
  context 'as a logged in user', js: true, pending: true, skip: true do
    include_context 'logged_in_as_user'

    given!(:machine) { create(:machine) }
    given!(:order) { create(:order_with_print) }
    given!(:scheduled_imprint) { order.imprints.first }
    background do
      allow_any_instance_of(SunspotMatchers::SunspotSearchSpy).to receive(:results) { [scheduled_imprint] }
    end

    background do
      scheduled_imprint.update_attributes(scheduled_at: Time.now, estimated_time: 1, machine: machine)
    end

    scenario 'I can set a print team for the day' do
      # click a link somewhere
      # select the "print team members" and assign their roles
      # expect this to be saved in the session
    end

    scenario 'I can confirm the data and teams for a screen print are exact' do
      visit machine_agenda_path(machine.id)
      click_link 'Confirm Imprint Data'
      # expect the print team to be there
      # expect calculated print time and calculated print speed to be there
      # Fill in confirmed print time
      # expect calculated setup time to be there
      # fill in confirmed setup time
      # click confirm data
      # check that metrics are in db
      # check that an activity was made, confirming accurate data
    end

    scenario 'I can confirm the data and teams for a screen print are different' do
      visit machine_agenda_path(machine.id)
      click_link 'Confirm Print Data'
      # expect the print team to be there
      # expect calculated print time and calculated print speed to be there
      # Fill in confirmed print time
      # expect calculated setup time to be there
      # fill in confirmed setup time with different data
      # click confirm data
      # check that metrics are in db
      # check that print_data is in fact, adjusted
      # check that an activity was made, adjusting data
    end
    scenario 'I can confirm the data and teams for an imprint group'
  end

  context 'as a logged in user with the admin role' do
    include_context 'logged_in_as_admin'

    scenario 'I can create a metric type for a screen print that counts delays', js: true, pending: true do
      visit root_path
      click_link 'Data'
      click_link 'Metrics'

      find("[data-original-title='New Metric Type']").click
      fill_in 'Name', with: 'Delay Counts'
      select 'ScreenPrintTrain', from: 'Metric Type Class'
      select 'Count', from: 'Measurement Type'
      # expect there to be an activity select
      # expect there not to be a start or end_activity
      # click_button 'Create'
    end

  end
end

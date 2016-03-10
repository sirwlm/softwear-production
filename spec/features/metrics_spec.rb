require 'rails_helper'

feature "Metrics", type: :feature do
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

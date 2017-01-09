require 'spec_helper'

feature 'Calendar', js: true do
  given!(:machine_1) { create(:machine) }
  given!(:machine_2) { create(:machine) }
  given!(:screen_train) { create(:screen_train) }
  given!(:scheduled_imprint) { create(:print, scheduled_at: Time.now, estimated_time: 1, machine: machine_1) }
  given!(:unscheduled_imprint) { create(:screen_print, scheduled_at: nil, estimated_time: 1, machine: machine_2) }

  background do
    # Use fake sunspot search
    screen_train.imprints << scheduled_imprint  
    allow(Sunspot).to receive(:search) { |*args, &block| FakeSunspotSearch.new(*args, &block) }
    
  end

  context 'as an administrator', no_ci: true do
    include_context 'logged_in_as_admin'

    scenario 'A user can view imprints on the calendar', view: true do
      visit dashboard_calendar_path
      expect(page).to have_content scheduled_imprint.name
    end

    scenario 'A user can click on an imprint to view its transition interface' do
      visit dashboard_calendar_path
      
      find('a', text: scheduled_imprint.name).click
      expect(page).to have_content 'Current State:'
      expect(page).to have_content scheduled_imprint.state.humanize.titleize
      expect(page).to have_content 'Close'
    end

    scenario 'A user can drag an imprint to change its scheduled time', pending: "This actually works but is nondeterministic", no_ci: true do
      visit dashboard_calendar_path
      find('a', text: scheduled_imprint.name).drag_to find('tr', text: '1pm')
      sleep 0.5
      # This is kind of arbitrary
      expect(scheduled_imprint.reload.scheduled_at.strftime('%I%p')).to eq  '02PM'
    end

    scenario "A user can select a machine and unschedule the imprint by dragging it to the dock" do
      visit dashboard_calendar_path

      find('.select2-choices').click
      find('.select2-result', text: scheduled_imprint.machine.name).click
      sleep 0.5

      find('a', text: scheduled_imprint.name).drag_to find('.event-receiver', text: machine_1.name)
      sleep 0.5

      expect(scheduled_imprint.reload.scheduled_at).to be_nil
      expect(page).to have_selector '.event-receiver', text: scheduled_imprint.name
    end

    scenario "A user can select a machine and schedule an imprint by dragging it onto the calendar" do
      visit dashboard_calendar_path

      find('.select2-choices').click
      find('.select2-result', text: machine_2.name).click
      sleep 0.5

      find('.unscheduled-imprint', text: unscheduled_imprint.name).drag_to find('tr', text: '1pm')
      sleep 0.5

      expect(scheduled_imprint.reload.scheduled_at).to_not be_nil
      expect(page).to have_selector 'a', text: scheduled_imprint.name
    end

    scenario 'A user can see the calender refresh and see changes on calender', refresh: true do
      visit dashboard_calendar_path

      find('.select2-choices').click
      find('.select2-result', text: machine_1.name).click

      expect(page).to have_content "#{scheduled_imprint.name}"
      scheduled_imprint.name = "This is the new name"
      scheduled_imprint.save
      new_name = scheduled_imprint.reload.name

      # sleep so that page can refresh
      sleep 8 

      expect(page).to have_content "#{new_name}"
    end

    context 'calendar events', calendar_entries: true do
      scenario 'are returned as disabled if completed' do 
        scheduled_imprint.state = "complete"
        scheduled_imprint.save

        visit calendar_events_machines_path(machine: machine_1, start: (Time.now - 2.hours).to_s, end: (Time.now + 2.hours).to_s, format: :json)
      
        expect(JSON.parse(page.find('pre').text)[0]["editable"]).to eq(false)
      end


      scenario 'are returned as enabled if not completed' do
        visit calendar_events_machines_path(machine: machine_1, start: (Time.now - 2.hours).to_s, end: (Time.now + 2.hours).to_s, format: :json)

        expect(JSON.parse(page.find('pre').text)[0]["editable"]).to eq(true)
      end
    end
  end
end

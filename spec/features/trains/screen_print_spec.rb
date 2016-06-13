require 'spec_helper'

feature 'Screen Print Trains', js: true do
  context "as an admin" do

    include_context 'logged_in_as_admin'
    let(:machine) { create(:machine) }

    scenario "I can create an order with a screen print" do
      create_order(
        name: 'Test Order',
        jobs: [
          {
            imprints: [
              {
                name: 'Test Job',
                description: 'Test Desc',
                machine: machine.name,
                type: 'Screen Print',
                estimated_time: 3,
                machine_print_count: 100
              }
            ]
          }
        ]
      )
      expect(page).to have_content('Order was successfully created')
      expect(page).to have_css('dd', text: 'Screen print')
    end

    context 'given an order with an imprint that is a screen print' do
      given(:order) { create(:order, jobs: [ create(:job_with_screen_print) ]) }
      given(:imprint) { order.jobs.first.imprints.first }


      scenario "I can transition a print state to completion", story_909: true, tag: true do
        visit order_path(order)
        within("#imprint-#{imprint.id}") do
          click_link 'Show Full Details'
        end
        sleep(1)
        success_transition :approve
        success_transition :start_setup
        select_from_select2 ScreenPrint::TRILOC_RESULTS.first
        success_transition :setup_complete
        success_transition :print_started
        success_transition :print_complete

        within('.train-category-success') do
          expect(page).to have_content('No actions available')
        end

        expect(imprint.reload.complete?).to be_truthy
      end

      context 'being printed', reschedule: true, reschedule_feature: true do
        background :each do
          imprint.update_column :state, :printing
        end

        scenario 'I can mark a screen print as needing rescheduling' do
          visit order_path(order)
          within("#imprint-#{imprint.id}") do
            click_link 'Show Full Details'
          end

          sleep 1
          success_transition :print_complete

          within '.train-category-delay' do
            fill_in 'public_activity_reason', with: 'too tired to print'
          end
          delay_transition :reschedule

          expect(page).to_not have_css ".train-state-button", text: "Rescheduled"

          expect(imprint.reload.reschedules.size).to eq 1
          expect(imprint.state).to eq 'pending_rescheduling'
        end
      end

      context 'that is rescheduled', reschedule: true, reschedule_feature: true, calendar_interaction: true do
        given(:new_imprint) { imprint.generate_rescheduled_imprint }

        background :each do
          imprint.machine = machine
          imprint.state = :pending_rescheduling
          imprint.save!

          expect(new_imprint.job).to eq imprint.job
          expect(new_imprint.machine).to eq imprint.machine

          # Use fake sunspot search
          allow(Sunspot).to receive(:search) { |*args, &block| FakeSunspotSearch.new(*args, &block) }
        end
        
        scenario 'I can schedule the new imprint, transitioning the state of the old one to "rescheduled"' do
          expect(new_imprint.reload.scheduled_at).to be_nil
          visit dashboard_calendar_path

          find('.select2-choices').click
          find('.select2-result', text: machine.name).click
          sleep 1.5

          find('.unscheduled-imprint', text: new_imprint.name).drag_to find('tr', text: '9am')
          sleep 0.5

          expect(new_imprint.reload.scheduled_at).to_not be_nil
          expect(imprint.reload.state).to eq "rescheduled"
          expect(imprint).to be_complete
        end

        scenario 'I cannot change its scheduled_at time' do
          original_scheduled_at = imprint.reload.scheduled_at
          visit dashboard_calendar_path
          find('.select2-choices').click
          find('.select2-result', text: machine.name).click
          sleep 1.5

          find('a', text: imprint.name).drag_to find('tr', text: '9am')
          sleep 0.5

          expect(imprint.reload.scheduled_at).to eq original_scheduled_at
        end
      end

      context 'that requires manager signoff' do

        given(:manager) { create(:admin) }

        before(:each) do
          imprint.update_attribute(:require_manager_signoff, true)
          imprint.update_column(:state, :setting_up)
        end

        scenario "I can transition a print state to completion", story_909: true do
          visit order_path(order)
          within("#imprint-#{imprint.id}") do
            click_link 'Show Full Details'
          end
          sleep(1)
          select_from_select2 ScreenPrint::TRILOC_RESULTS.last
          success_transition :setup_complete
          select_from_select2 manager.full_name
          success_transition :production_manager_approved
          success_transition :print_started
          success_transition :print_complete

          within('.train-category-success') do
            expect(page).to have_content('No actions available')
          end

          expect(imprint.reload.complete?).to be_truthy
          expect(imprint.completed_at).not_to be_nil
        end
      end
    end
  end
end

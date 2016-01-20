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

    context 'given an order with an imprint that is a screen print'  do
      given(:order) { create(:order, jobs: [ create(:job_with_screen_print) ]) }
      given(:imprint) { order.jobs.first.imprints.first }


      scenario "I can transition a print state to completion", story_909: true do
        visit order_path(order)
        within("#imprint-#{imprint.id}") do
          click_link 'Show Full Details'
        end
        sleep(1)
        success_transition :approve
        success_transition :start_set_up
        success_transition :set_up_complete
        success_transition :print_started
        success_transition :print_complete

        within('.train-category-success') do
          expect(page).to have_content('No actions available')
        end

        expect(imprint.reload.complete?).to be_truthy
      end

      context 'that requires manager signoff' do

        given(:manager) { create(:admin) }

        before(:each) do
          imprint.update_attribute(:require_manager_signoff, true)
          imprint.update_column(:state, :setting_up)
        end

        scenario "I can transition a print state to completion", story_909: true, current: true do
          visit order_path(order)
          within("#imprint-#{imprint.id}") do
            click_link 'Show Full Details'
          end
          sleep(1)
          success_transition :set_up_complete
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

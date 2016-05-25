require 'spec_helper'

feature 'Digital Prints', digital_print: true, js: true do

  context 'as an admin' do
    include_context 'logged_in_as_admin'
    let(:machine) { create(:machine) }

    scenario 'I can create an order with a digital print' do
      create_order(
          name: 'Test Order',
          jobs: [
              {
                  imprints: [
                      {
                          name: 'Test Job',
                          description: 'Test Desc',
                          machine: machine.name,
                          type: 'Digital Print',
                          estimated_time: 3,
                          machine_print_count: 100
                      }
                  ]
              }
          ]
      )
      expect(page).to have_content('Order was successfully created')
      expect(page).to have_css('dd', text: 'Digital print')
    end

    context 'given an order with an imprint that is a digital print'  do
      given(:order) { create(:order, jobs: [ create(:job_with_digital_print) ]) }
      given(:imprint) { order.jobs.first.imprints.first }
      given!(:user_1) { create(:user, first_name: 'User', last_name: 'One') }
      given!(:user_2) { create(:user, first_name: 'User', last_name: 'Two') }


      scenario 'I can transition a print state to completion', story_1099: true, story_909: true  do
        visit order_path(order)
        within("#imprint-#{imprint.id}") do
          click_link 'Show Full Details'
        end
        sleep(1)
        success_transition :approve
        success_transition :schedule
        success_transition :preproduction_complete
        success_transition :final_test_print_printed
        success_transition :start_printing
        select_from_select2 'User One', 'User Two'
        success_transition :completed

        within('.train-category-success') do
          expect(page).to have_content('No actions available')
        end

        expect(imprint.reload.complete?).to be_truthy
        expect(imprint.completers - [user_1, user_2]).to be_empty
        expect(page).to have_content 'Completed by User One, User Two'
      end

      context 'that requires manager signoff' do

        let(:manager) { create(:admin) }

        before(:each) do
          imprint.update_attribute(:require_manager_signoff, true)
          imprint.update_column(:state, :pending_final_test_print)
        end

        scenario 'I can transition a print state to completion', story_909: true do
          visit order_path(order)
          within("#imprint-#{imprint.id}") do
            click_link 'Show Full Details'
          end
          sleep(1)

          success_transition :final_test_print_printed
          select_from_select2 manager.full_name
          success_transition :production_manager_approved
          success_transition :start_printing
          find('.select2-container-multi').click
          first('.select2-result-selectable').click
          success_transition :completed

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

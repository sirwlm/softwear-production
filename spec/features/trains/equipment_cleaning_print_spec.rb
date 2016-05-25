require 'spec_helper'

feature 'Equipment Cleaning Prints', equipment_cleaning_print: true, js: true do

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
                          type: 'Equipment Cleaning Print',
                          estimated_time: 3,
                          machine_print_count: 100
                      }
                  ]
              }
          ]
      )
      expect(page).to have_content('Order was successfully created')
      expect(page).to have_css('dd', text: 'Equipment cleaning print')
    end

    context 'given an order with an imprint that is a equipment cleaning print'  do
      given(:order) { create(:order, jobs: [ create(:job_with_equipment_cleaning_print) ]) }
      given(:imprint) { order.jobs.first.imprints.first }


      scenario 'I can transition a print state to completion', story_909: true  do
        visit order_path(order)
        within("#imprint-#{imprint.id}") do
          click_link 'Show Full Details'
        end
        sleep(1)
        success_transition :approve
        success_transition :schedule
        success_transition :put_equipment_in_dryer
        success_transition :put_into_stink_chest
        success_transition :repacked_bag

        within('.train-category-success') do
          expect(page).to have_content('No actions available')
        end

        expect(imprint.reload.complete?).to be_truthy
        expect(imprint.reload.completed_at).not_to be_nil
      end
    end
  end
end

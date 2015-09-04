require 'spec_helper'

feature 'Generic Print Trains', print_spec: true, js: true do

  context "as an admin" do

    include_context 'logged_in_as_admin'
    let(:machine) { create(:machine) }

    scenario "I can create an order with a print" do
      create_order(
        name: 'Test Order', 
        jobs: [
          {
            imprints: [
              {
                name: 'Test Job',
                description: 'Test Desc',
                machine: machine.name,
                type: 'Print', 
                estimated_time: 3,
                machine_print_count: 100
              }
            ] 
          }
        ]
      )      
      expect(page).to have_content('Order was successfully created')
      expect(page).to have_css('dd', text: 'Print')
    end
    
    context 'given an order with an imprint that is a print', current: true do
      given(:order) { create(:order_with_print) }
      given(:imprint) { order.jobs.first.imprints.first }
     
      before(:each) do 
        visit order_path(order)
        within("#imprint-#{imprint.id}") do 
          click_link 'Show Full Details'
        end
        sleep(1)
      end


      scenario "I can transition a print state to completion", story_909: true do 
        success_transition :approve 
        success_transition :at_the_press
        success_transition :printing_complete
        
        within('.train-category-success') do 
          expect(page).to have_content('No actions available')
        end
        
        expect(imprint.reload.complete?).to be_truthy
      end
    
    end
  end
end

require 'spec_helper'

feature 'Stage For Pickup Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'

    given(:manager) { create(:admin) }
    given(:stage_for_pickup_train) { create(:stage_for_pickup_train) }
    given(:order) { create(:order) }

    scenario 'The trains successful stations are Pending Packing, Ready to Stage, Staged', story_868: true do

      visit show_train_path(:stage_for_pickup_train, stage_for_pickup_train)

      expect(page).to have_css('.alert-info', text: 'Pending Packing')
      success_transition :packed

      expect(page).to have_css('.alert-info', text: 'Ready To Stage')
      find('#stage_for_pickup_train_inventory_location').set('That one shelf')
      success_transition :staged

      expect(page).to have_css('.alert-info', text: 'Staged')
      within('.train-category-success') do
        expect(page).to have_no_selector('button')
      end

    end

    scenario 'I can add a store delivery train to an order' do
      visit order_path(order)
      within("#order-post-production .post_production_trains") do
        click_link("+")
      end
      sleep(1)
      select("StageForPickupTrain", from: 'train_class')
      click_button("Create Train")
      expect(page).to have_content "Stage for pickup train"
    end

    scenario 'When I enter in the inventory location through the transition it shows up in the FBABaggingTrain', pending: 'Stefan'
    scenario 'When I enter in the inventory location through the Edit Form it shows up in the FBABaggingTrain', pending: 'Stefan'

  end
end

require 'spec_helper'

feature 'Stage For FBA Bagging Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
    
    given(:manager) { create(:admin) }
    given(:stage_for_fba_bagging_train) { create(:stage_for_fba_bagging_train) }
    given(:fba_bagging_train) { create(:fba_bagging_train, order: stage_for_fba_bagging_train.order) }
    given(:order) { create(:order) }

    scenario 'The trains successful stations are Pending Packing, Ready to Stage, Staged', story_868: true do
      fba_bagging_train
      visit show_train_path(:stage_for_fba_bagging_train, stage_for_fba_bagging_train)
      
      expect(page).to have_css('.alert-info', text: 'Pending Packing')
      success_transition :packed

      expect(page).to have_css('.alert-info', text: 'Ready To Stage')
      find('#stage_for_fba_bagging_train_inventory_location').set('That one shelf')
      success_transition :staged
      
      expect(page).to have_css('.alert-info', text: 'Staged')
      within('.train-category-success') do 
        expect(page).to have_no_selector('button')
      end      

    end

    scenario 'I can add a stage_for_fba_bagging_train to an order' do 
      visit order_path(order)
      within("#order-post-production .post_production_trains") do 
        click_link("+")
      end
      sleep(1)
      select("StageForFbaBaggingTrain", from: 'train_class')
      click_button("Create Train")
      expect(page).to have_content "Stage For Fba Bagging Train"
    end

    context 'FbaBaggingTrain inventory_location specs' do

      before(:each) do
        visit order_path(order)
        within("#order-post-production .post_production_trains") do
          click_link("+")
        end
        sleep(1)
        select("FbaBaggingTrain", from: 'train_class')
        click_button("Create Train")
        sleep(1)
        within("#order-post-production .post_production_trains") do
          click_link("+")
        end
        select("StageForFbaBaggingTrain", from: 'train_class')
        click_button("Create Train")
        sleep(1)
        within(".stage-for-fba-bagging-train-panel") do
          click_link("Show Full Details")
        end
        sleep(1)
        click_button("Packed")
        sleep(1)
        within(".train-category-success") do
          find("#stage_for_fba_bagging_train_inventory_location").set("That one shelf")
        end
        sleep(1)
        click_button("Staged")
        sleep(1)
        click_button("Close")
        sleep(1)
      end

      scenario 'When I enter in the inventory location through the transition it shows up in the FBABaggingTrain' do
        #only one fba train at this point
        fbabagging = FbaBaggingTrain.first
        expect(fbabagging.inventory_location).to eq("That one shelf")
      end
      
      scenario 'When I enter in the inventory location through the Edit Form it shows up in the FBABaggingTrain' do
        within(".stage-for-fba-bagging-train-panel") do
          click_link("Show Full Details")
        end
        find("#stage_for_fba_bagging_train_inventory_location").set("The other shelf")
        sleep(1)
        click_button("Update Stage for fba bagging train")
        sleep(1)

        #only one fba train here
        fbabagging = FbaBaggingTrain.first
        expect(fbabagging.inventory_location).to eq("The other shelf")
      end
    end
  end
end

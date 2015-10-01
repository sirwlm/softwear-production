require 'spec_helper'

feature 'Stage For FBA Bagging Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
    
    given(:manager) { create(:admin) }
    given(:stage_for_fba_bagging_train) { create(:stage_for_fba_bagging_train) }
    given(:order) { create(:order) }

    scenario 'The trains successful stations are Pending Packing, Ready to Stage, Staged', story_868: true do
      
      visit show_train_path(:stage_for_fba_bagging_train, stage_for_fba_bagging_train)
      
      expect(page).to have_css('.alert-info', text: 'Pending Packing')
      success_transition :packed

      expect(page).to have_css('.alert-info', text: 'Ready To Stage')
      find('#stage_for_fba_bagging_train_location').set('That one shelf')
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
      expect(page).to have_content "Stage for fba bagging train"
    end

  end
end
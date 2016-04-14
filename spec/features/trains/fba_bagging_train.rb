require 'spec_helper'

feature 'Fba Bagging Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
   
    given(:stage_for_fba) { create(:stage_for_fba_bagging_train) } 
    given(:fba_bagging_train) { create(:fba_bagging_train, order_id: stage_for_fba.order.id) }

    scenario 'The trains successful stations are Bagging in Progress, Bagged', story_868: true do
      
      visit show_train_path(:fba_bagging_train, fba_bagging_train)
      
      expect(page).to have_css('.alert-info', text: 'Ready To Bag')
      within('.train-category-success') do 
        click_button 'Bagging started'
        sleep(1)
      end

      expect(page).to have_css('.alert-info', text: 'Bagging In Progress')
      within('.train-category-success') do 
        click_button 'Bagging complete'
        sleep(1)
      end

      expect(page).to have_css('.alert-info', text: 'Bagged')
      within('.train-category-success') do 
        expect(page).to have_no_selector('button')
      end

      #checks for inventory location
      expect(page).to have_content("#{stage_for_fba.location}")      

    end
    
    scenario 'The train can delay and restart in the bagging_in_progress state', current: true, story_868: true do
      
      visit show_train_path(:fba_bagging_train, fba_bagging_train)
      
      expect(page).to have_css('.alert-info', text: 'Ready To Bag')

      within('.train-category-delay') do 
        expect(page).to have_no_selector('button')
      end
      within('.train-category-success') do 
        click_button 'Bagging started'
        sleep(1)
      end

      within("form[action='#{transition_train_path(:fba_bagging_train, fba_bagging_train, :delayed)}']") do 
        find('#public_activity_reason').set('Delayed Reason')        
        click_button 'Delayed'
        sleep(1)
      end

      expect(page).to have_css('.alert-info', text: 'Delayed')
      within('.train-category-success') do 
        click_button 'Bagging restarted'
        sleep(1)
      end

      expect(page).to have_css('.alert-info', text: 'Bagging In Progress')
      within('.train-category-success') do 
        click_button 'Bagging complete'
        sleep(1)
      end

      expect(page).to have_css('.alert-info', text: 'Bagged')
      expect(page).to have_no_selector('button')

    end
  end
end

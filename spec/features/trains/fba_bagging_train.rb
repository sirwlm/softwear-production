require 'spec_helper'

feature 'Fba Bagging Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
   
    given(:stage_for_fba) { create(:stage_for_fba_bagging_train) } 
    given(:fba_bagging_train) { create(:fba_bagging_train, order_id: stage_for_fba.order.id) }

    context 'The fba_bagging_train has associated production_trains' do
      scenario 'The production trains are not completed' do
        visit show_train_path(:fba_bagging_train, fba_bagging_train)
        sleep 1
        
        expect(page).to have_content("Printed")
        expect(fba_bagging_train.printed?).to eq("No")
        expect(page)
        .to have_content(fba_bagging_train.order.production_trains.first.scheduled_at.strftime('%Y-%m-%d %I:%M%P'))
      end

      scenario 'The production trains are completed' do
        expect(fba_bagging_train.printed?).to eq("No")

        fba_bagging_train.order.production_trains.each do |pt|
          pt.state = "complete"
          pt.save
          pt.reload
        end

        visit show_train_path(:fba_bagging_train, fba_bagging_train)

        expect(fba_bagging_train.reload.printed?).to eq("Yes")
        expect(page).to have_content(fba_bagging_train.reload.printed?)
      end
    end

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
      expect(page).to have_content("#{stage_for_fba.inventory_location}")      

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

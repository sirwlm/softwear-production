require 'spec_helper'

feature "ScreenTrains", type: :feature, js: true do

  context 'when logged in as a user' do

    given!(:manager) { create(:admin) }
    given(:order) { create(:order) }
    given!(:screen_train) { create(:screen_train) }

    include_context 'logged_in_as_user'

    scenario 'I can add a screen_train to an order at order#index' do 
      visit order_path(order)
      within("#order-pre-production .pre_production_trains") do 
        click_link("+")
      end
      sleep(1)
      select("ScreenTrain", from: 'train_class')
      click_button("Create Train")
      expect(page).to have_content "Screen train"
    end
    
    scenario 'I can add a screen_train to an order at screen_train#new'
      
    scenario 'I can view a list of screen_trains and filter on their fields', pending: true do 
      visit root_path
      click_link "Screens"
      click_link "Pre-Production"
      expect(true).to be_falsy
      # check for table
      # check for filter
#      expect(true).to be_false
    end

    scenario 'I can edit the fields in a screen train', pending: true do 
      visit screen_trains_path
      expect(true).to be_falsy
      # within table row that has the screen train's id click edit
      # edit the fields
      # save it
      # saving it will bring up the screen with the transition options
    end

    context 'A screen train has incomplete proof request data' do 
      given(:screen_train) { create(:screen_train) }
      
      scenario 'I cannot transition from pending_sep_request via sep_request_complete' do 
        visit show_train_path(:screen_train, screen_train)
        within('.train-category-success') do 
          expect(page).to have_no_selector('button')
        end
      end  
     
    end

    context 'given a screen is pending_screens or complete' do 
      background(:each) { screen_train.update_attribute(:state, :pending_screens) }
    
      scenario 'I can delay it due to a bad_separation', current: true do 
        visit show_train_path(:screen_train, screen_train)
        within('.train-category-delay') do
          expect(page).to have_selector('button', text: 'Bad separation')
        end

        success_transition :screens_assigned
        within('.train-category-delay') do
          expect(page).to have_selector('button', text: 'Bad separation')
        end
        
        fill_in("public_activity_reason", with: 'Bad Sep' )
        delay_transition :bad_separation
        expect(page).to have_text 'Pending Separation'

      end  
    end

    context 'given a screen is complete' do 
      background(:each) { screen_train.update_attribute(:state, :complete) }
    
      scenario 'I can delay it due to a bad_burnout', current: true do 
        visit show_train_path(:screen_train, screen_train)

        within('.train-category-delay') do
          expect(page).to have_selector('button', text: 'Bad burnout')
        end
        
        delay_transition :bad_burnout
        expect(page).to have_text 'Pending Screens'

      end  
    end
    context 'given a screen is pending_screens or complete' do 
      background(:each) { screen_train.update_attribute(:state, :pending_screens) }
    
      scenario 'I can delay it due to a bad_separation' do 
        visit show_train_path(:screen_train, screen_train)
        within('.train-category-delay') do
          expect(page).to have_selector('button', text: 'Bad separation')
        end

        success_transition :screens_assigned
        within('.train-category-delay') do
          expect(page).to have_selector('button', text: 'Bad separation')
        end
      end  
    end

    context 'given a screen is ready to transition to complete but screens arent assigned' do 
      
      background(:each) { screen_train.update_attribute(:state, :pending_screens) }
      
      scenario 'I cannot transition it to complete', pending: true  do 
        visit show_train_path(:screen_train, screen_train)
        within('.train-category-success') do 
          expect(page).to have_no_selector('button')
        end
      end 
    end

    context 'given a screen train has all of the proof request data and all screens assigned' do 

      background { allow_any_instance_of(ScreenTrain).to receive(:proof_request_data_complete?).and_return(true) }
      background { allow_any_instance_of(ScreenTrain).to receive(:all_screens_assigned?).and_return(true) }

      context 'and is not a new separation with' do 
        
        given!(:screen_train) { create(:screen_train, new_separation: false) }

        scenario 'I can transition it to a completed state', story_868: true do
          visit show_train_path(:screen_train, screen_train)

          expect(page).to have_css('.alert-info', text: 'Pending Sep Request')
          success_transition :sep_request_complete

          expect(page).to have_css('.alert-info', text: 'Pending Approval')
          select(manager.full_name, from: "screen_train_signed_off_by_id" )
          success_transition :approved
          
          expect(page).to have_css('.alert-info', text: 'Pending Screens')
          success_transition :screens_assigned

          expect(page).to have_css('.alert-info', text: 'Complete')
          within('.train-category-success') do 
            expect(page).to have_no_selector('button')
          end
          
          expect(screen_train.reload.complete?).to be_truthy
        end
      end


      context 'and is a new separation' do 
        
        given!(:screen_train) { create(:screen_train, new_separation: true) }

        scenario 'I can transition it to a completed state', story_868: true do
          
          visit show_train_path(:screen_train, screen_train)
          
          expect(page).to have_css('.alert-info', text: 'Pending Sep Request')
          success_transition :sep_request_complete
          
          expect(page).to have_css('.alert-info', text: 'Pending Sep Assignment')
          select(manager.full_name, from: "screen_train_assigned_to_id" )
          success_transition :assigned
          
          expect(page).to have_css('.alert-info', text: 'Pending Separation')
          success_transition :separated

          expect(page).to have_css('.alert-info', text: 'Pending Approval')
          select(manager.full_name, from: "screen_train_signed_off_by_id" )
          success_transition :approved
          
          expect(page).to have_css('.alert-info', text: 'Pending Screens')
          success_transition :screens_assigned

          expect(page).to have_css('.alert-info', text: 'Complete')
          within('.train-category-success') do 
            expect(page).to have_no_selector('button')
          end
          expect(screen_train.reload.complete?).to be_truthy
        
        end
      end

    end
  end
end

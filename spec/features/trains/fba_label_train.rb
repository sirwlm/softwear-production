require 'spec_helper'

feature 'Fba Label Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
    
    given(:order) { create(:order) }
    given(:fba_label_train) { create(:fba_label_train, order: order) }

    scenario 'The trains successful stations are Labels Staged, Labels Printed', story_868: true do
      
      visit show_train_path(:fba_label_train, fba_label_train)
      
      expect(page).to have_css('.alert-info', text: 'Pending Labels')
      within('.train-category-success') do 
        click_button 'Labels printed'
        sleep(1.5)
      end

      expect(page).to have_css('.alert-info', text: 'Labels Printed')
      within('.train-category-success') do 
        click_button 'Labels staged'
        sleep(1.5)
      end

      expect(page).to have_css('.alert-info', text: 'Labels Staged')
      within('.train-category-success') do 
        expect(page).to have_no_selector('button')
      end      

    end
  
    context 'without the admin role', current: true do
      background { allow_any_instance_of(User).to receive(:admin?) { false } }
      
      scenario 'I cannot destroy an fba label train' do 
        visit order_path(fba_label_train.order)
        expect(page).to_not have_css(".destroy-train-link") 
      end 
    end
  
    context 'with the admin role', current: true do
      scenario 'I can destroy an fba label train' do 
        visit order_path(fba_label_train.order)
        find('.pre_production_trains .destroy-train-link').click
        sleep 1
        page.driver.browser.switch_to.alert.accept
        sleep 2 
        expect(FbaLabelTrain.exists?(fba_label_train.id)).to be_falsy
      end 
    end
  end

end

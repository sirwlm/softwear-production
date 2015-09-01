require 'spec_helper'

feature 'Fba Label Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
    
    given(:fba_label_train) { create(:fba_label_train) }

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
  end
end

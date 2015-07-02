require 'spec_helper'

feature 'Imprints' do

  given(:print) { create(:print) }
 
  context "as an admin" do 
    include_context 'logged_in_as_admin'
    
    given!(:machine) { create(:machine) } 
    
    scenario 'I can search imprints', story_460: true do
      visit imprints_path
      fill_in 'q[text]', with: print.name
      click_button 'Search'
      expect(Sunspot.session).to be_a_search_for(Imprint)
    end
   
    scenario "A production manager can require an imprint be signed off on", js: true, story_694: true do 
      visit new_order_path
      fill_in 'Name', with: 'Require signoff on order'
      click_link 'New Job'

      within '.order-jobs' do
        fill_in 'Name', with: 'A job'
        click_link 'New Imprint'
        within '.job-imprints' do
          fill_in 'Name', with: 'An imprint'
          fill_in 'Description', with: 'Here it is - the imprint'
          select machine.name, from: 'Machine'
          fill_in 'Estimated Time in Hours', with: 3
          fill_in 'Machine Print Count', with: 7
          choose('Yes')
        end
      end
      click_button 'Create Order'
      sleep 1
      click_link "An imprint"
      expect(page).to have_content 'This Imprint Requires Signoff' 
    end
  end

  context 'as a user' do 
    include_context 'logged_in_as_user'
    
    given!(:admin) { create(:admin) }
    
    scenario "I can transition an imprint state", js: true, story_694: true do
      visit imprint_path(print)
      expect(page).to have_content "Current State is Pending Approval"
      click_button 'Approve'

      expect(page).to have_content "Current State is Ready To Print"
      expect(print.reload.state).to eq 'ready_to_print'
    end  
      
    context 'when an imprint requires manager sign off', js: true do 
      
      given(:imprint) { create(:print, type: 'ScreenPrint', require_manager_signoff: true) }
      before(:each) { imprint.update_column(:state, :pending_production_manager_approval) }
     
      scenario "When an imprint requires manager sign off, the manager needs to enter their password" do 
        visit imprint_path(imprint)
        expect(page).to have_content "Current State is Pending Production Manager Approval"
        select2_tag(admin.full_name, from: "approved by")
        fill_in :manager_password, with: '2_1337_4_u'
        click_button "Production manager approved" 
        expect(page).to have_content "Current State is In Production"
      end
    end
  end

end

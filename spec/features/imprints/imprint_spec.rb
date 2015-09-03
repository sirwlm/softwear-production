require 'spec_helper'

feature 'Imprints' do


  context "as an admin" do
    include_context 'logged_in_as_admin'
  
    scenario "I can transition an imprint state", js: true, story_694: true, current: true do
      visit show_train_path(:print, print.id)
      expect(page).to have_content "Current State: Pending Approval"
      click_button 'Approve'
      sleep 1
      byebug
      expect(page).to have_content "Current State: Ready To Print"
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

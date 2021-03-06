require 'spec_helper'

feature 'Preproduction notes', story_821: true, js: true do
  given(:order) { create(:order_with_print) }
  given(:job) { order.jobs.first }

  context 'As a non-manager user' do
    include_context 'logged_in_as_user'

    given!(:admin) { create(:admin) }
    given!(:preproduction_notes) { create(:preproduction_notes_train, job: job, state: :pending_review) }

    scenario 'I can approve preproduction notes with the valid cedentials of a manager' do
      visit show_train_path :preproduction_notes_train, preproduction_notes

      find('.select2-container').click
      find('.select2-result-label', text: admin.email).click
      find('#preproduction_notes_train_manager_password').set 'theAdminP4ssword'
      allow_any_instance_of(User).to receive(:valid_password?).and_return true

      click_button 'Approve'

      expect(page).to have_content 'Current State: Approved'
      expect(preproduction_notes.reload.state).to eq 'approved'
    end

    scenario 'I cannot approve preproduction notes without the valid cedentials of a manager' do
      visit show_train_path :preproduction_notes_train, preproduction_notes

      find('.select2-container').click
      find('.select2-result-label', text: admin.email).click
      find('#preproduction_notes_train_manager_password').set 'what-password?'
      allow_any_instance_of(User).to receive(:valid_password?).and_return false

      click_button 'Approve'

      expect(page).to have_content 'Manager password is incorrect'
      expect(preproduction_notes.reload.state).to eq 'pending_review'
    end
  end
end

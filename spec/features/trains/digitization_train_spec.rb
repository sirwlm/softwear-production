require 'spec_helper'

feature 'Digitization Trains', digitization_spec: true, js: true do
  context 'as a logged in user'do
    given!(:digitization_train) { create(:digitization_train) }
    
    include_context 'logged_in_as_admin'

    context 'given digitization trains' do
      scenario 'I can assign stitch counts' do
        expect(digitization_train.stitch_count).to be_nil
        visit show_train_path(:digitization_train, digitization_train) 
        fill_in "Stitch count", with: 100

        click_button "Update Digitization train"

        expect(digitization_train.reload.stitch_count).to eq(100)
      end

      scenario 'I can assign stitch counts and laser stitch counts and see the difference as non-laser stitch counts' do
        visit show_train_path(:digitization_train, digitization_train)

        fill_in "Stitch count", with: 100
        find(:css, '.uses-laser').click
        fill_in "Laser stitch count", with: 10
        expect(page).to have_content "Non-Laser Stitch Count"
        expect(page).to have_content "#{100 - 10}"
      end
    end
  end
end

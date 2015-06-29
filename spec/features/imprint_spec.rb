require 'spec_helper'

feature 'Imprints' do
  include_context 'logged_in_as_user'

  given!(:admin) { create(:admin) }
  given!(:user) { create(:user) }
  given!(:imprint) { create(:imprint)}
  given(:print) { create(:print) }
  given(:print_to_sign_off) { create(:print, current_state: :pending_tape_off) }
  given!(:machine) { create(:machine) }
  
  scenario 'a production manager can search imprints', story_460: true do
    visit imprints_path
    fill_in 'q[text]', with: imprint.name
    click_button 'Search'
    expect(Sunspot.session).to be_a_search_for(Imprint)
  end

  scenario "An imprint's state can be transitioned", js: true, story_694: true do
    visit imprint_path(print)
    expect(page).to have_content "Current State is Pending Approval"
    click_button 'Approve'

    expect(page).to have_content "Current State is Ready To Print"
    expect(print.reload.state).to eq 'ready_to_print'
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

  scenario "When an imprint requires manager sign off, the manager needs to enter their password"

end

require 'spec_helper'

feature 'Imprints' do
  include_context 'logged_in_as_user'

  given!(:admin) { create(:admin) }
  given!(:user) { create(:user) }
  given!(:imprint) { create(:imprint)}
  given(:print) { create(:print) }

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
end

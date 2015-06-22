require 'spec_helper'

feature 'Imprints' do
  include_context 'logged_in_as_user'

  given!(:admin) { create(:admin) }
  given!(:user) { create(:user) }
  given!(:imprint) { create(:imprint)}

  scenario 'a production manager can search imprints', story_460: true do
    visit imprints_path
    fill_in 'q[text]', with: imprint.name
    click_button 'Search'
    expect(Sunspot.session).to be_a_search_for(Imprint)
  end

  scenario "An imprint's state can be transitioned", story_694: true do
    visit imprint_path(imprint)
    expect(page).to have_content "Current State is Pending approval"
    click_button '(WHATEVER THE NEXT EVENT IS)'

    expect(page).to have_content "Current State is WHATEVER THE STATE SHOULD BE"
    expect(imprint.reload.state).to eq 'WHATEVER THE STATE SHOULD BE'
  end
end

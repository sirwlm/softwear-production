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

end
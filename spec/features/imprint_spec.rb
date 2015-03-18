require 'spec_helper'

feature 'Imprints', user_spec: true, js: true, story_115: true do
  context 'with valid credentials' do
    given!(:admin) { create(:admin) }
    given!(:user) { create(:user) }

    scenario 'a production manager can search imprints'

  end

end
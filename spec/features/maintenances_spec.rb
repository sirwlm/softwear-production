require 'spec_helper'

feature 'Maintenances' do
  given(:maintenance) { create :maintenance }
  given(:maintenances) do
    [maintenance].tap do |m|
      allow(m).to receive(:current_page).and_return 1
      allow(m).to receive(:limit_value).and_return 1
      allow(m).to receive(:total_pages).and_return 1
    end
  end

  context 'As a logged in user', js: true do
    include_context 'logged_in_as_user'

    scenario 'I can view the list of maintenances', story_111: true do
      allow(Maintenance).to receive(:search).and_return double('search results', results: maintenances)
      visit maintenances_path

      expect(page).to have_content maintenance.name
    end
  end

  context "As a logged in admin", js: true do
    include_context 'logged_in_as_admin'
    scenario 'I can create a maintenance', story_111: true do
      visit new_maintenance_path

      fill_in 'Name', with: 'what up'
      fill_in 'Description', with: 'This is the new maintenance'

      click_button 'Create Maintenance'

      expect(page).to have_content 'Maintenance was successfully created'
      expect(Maintenance.where(
        name:           'what up',
        description:    'This is the new maintenance'
      ))
        .to exist
    end
  end
end

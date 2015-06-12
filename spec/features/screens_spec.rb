require 'spec_helper'

feature 'Screen Features', js: true do
  given!(:s1) { create(:screen) }
  given!(:s2) { create(:screen, frame_type: 'Roller') }
  given!(:s3) { create(:screen, dimensions: '25x36') }
  given!(:s4) { create(:screen, mesh_type: '160') }
  given!(:s5) { create(:screen, state: 'ready_to_coat') }
  given!(:s6) { create(:screen, frame_type: 'Static') }
  given!(:user) { create(:user) }

  before(:each) do
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    visit status_screens_path
  end

  context 'can filter by a single field' do
    it 'can filter by only Frame Type' do
      select2_tag("Panel", from: 'Frame Type')
      click_button 'Filter'
      expect(page).to have_content('Panel')
      expect(page).not_to have_content('Roller')
    end
    it 'can filter by only Mesh Type' do
      select2_tag("160", from: 'Mesh Type')
      click_button 'Filter'
      expect(page).to have_content('160')
      expect(page).not_to have_content('110')
    end
    it 'can filter by only Dimensions' do
      select2_tag("25x36", from: 'Dimensions')
      click_button 'Filter'
      expect(page).to have_content('25x36')
      expect(page).not_to have_content('23x31')
    end
    it 'can filter by only State' do
      select2_tag("Ready to coat", from: 'State')
      click_button 'Filter'
      expect(page).to have_content('Ready To Coat')
      expect(page).not_to have_content('In Production')
    end
  end

  context 'can filter by multiple fields' do
    it 'can filter by two frame types' do
      select2_tag("Static", from: 'Frame Type')
      select2_tag("Panel", from: 'Frame Type')
      click_button 'Filter'
      expect(page).to have_content('Panel')
      expect(page).to have_content('Static')
      expect(page).not_to have_content('Roller')
    end
  end
  
  scenario 'can filter and unfilter' do
    select2_tag("Static", from: 'Frame Type')
    select2_tag("Panel", from: 'Frame Type')
    click_button 'Filter'
    expect(page).to have_content('Panel')
    expect(page).to have_content('Static')
    expect(page).not_to have_content('Roller')

    page.first(".select2-search-choice-close").click
    page.first(".select2-search-choice-close").click
    click_button 'Filter'
    expect(page).to have_content('Panel')
    expect(page).to have_content('Static')
    expect(page).to have_content('Roller')
  end
end

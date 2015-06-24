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
  end

  context 'when I change the state of a screen' do
    scenario 'I see success for 2 seconds, and then the modal closes', story_677: true do
      visit status_screens_path
      s1.update_attributes! state: :ready_to_reclaim
      find('#screen-id').set s1.id
      click_button 'Look Up Screen'
      sleep 0.5
      click_link 'Reclaimed'
      wait_for_ajax
      expect(page).to have_content 'Updated Screen State'
      expect(page).to have_content 'Current State is Reclaimed And Drying'
      sleep 1
      expect(page).to have_content 'Current State is Reclaimed And Drying'
      sleep 2
      expect(page).to_not have_content 'Current State is Reclaimed And Drying'
    end
  end

  context 'can filter by a single field' do
    it 'can filter by only Frame Type' do
      visit status_screens_path
      select2_tag("Panel", from: 'Frame Type')
      click_button 'Filter'
      expect(page).to have_content('Panel')
      expect(page).not_to have_content('Roller')
    end
    it 'can filter by only Mesh Type' do
      visit status_screens_path
      select2_tag("160", from: 'Mesh Type')
      click_button 'Filter'
      expect(page).to have_content('160')
      expect(page).not_to have_content('110')
    end
    it 'can filter by only Dimensions' do
      visit status_screens_path
      select2_tag("25x36", from: 'Dimensions')
      click_button 'Filter'
      expect(page).to have_content('25x36')
      expect(page).not_to have_content('23x31')
    end
    it 'can filter by only State' do
      visit status_screens_path
      select2_tag("Ready to coat", from: 'State')
      click_button 'Filter'
      expect(page).to have_content('Ready To Coat')
      expect(page).not_to have_content('In Production')
    end
  end

  context 'can filter by multiple fields' do
    it 'can filter by two frame types' do
      visit status_screens_path
      select2_tag("Static", from: 'Frame Type')
      select2_tag("Panel", from: 'Frame Type')
      click_button 'Filter'
      expect(page).to have_content('Panel')
      expect(page).to have_content('Static')
      expect(page).not_to have_content('Roller')
    end
  end
  
  scenario 'can filter and unfilter' do
    visit status_screens_path
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
  
  scenario 'can sort columns', story_691: true do
    visit status_screens_path
    expect(page).to have_css('th.tablesorter-header')
    page.find('th.tablesorter-header').click
  end

  context 'fast scanning', story_546: true do
    before(:each) do
      visit fast_scan_screens_path
    end

    it 'can advance a screen state' do
      select2("in_production", from: 'Expected Current State')
      select2("removed_from_production", from: 'Expected Transition')
      fill_in('screen_id', :with => '1')
      click_button 'Transition'
      sleep 1
      wait_for_ajax
      expect(page).to have_content "Hooray! Updated Screen State"
    end

    it 'properly raises error upon invalid state change attempt' do
      select2("new", from: 'Expected Current State')
      select2("broke", from: 'Expected Transition')
      fill_in('screen_id', :with => '1')
      click_button 'Transition'
      sleep 1
      wait_for_ajax
      expect(page).to have_content "Failed to update screen."
    end
  end

end

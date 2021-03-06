require 'spec_helper'

feature 'Screen Features', js: true do
  given!(:s1) { create(:screen) }
  given!(:s2) { create(:screen, frame_type: 'Roller') }
  given!(:s3) { create(:screen, dimensions: '25x36') }
  given!(:s4) { create(:screen, mesh_type: '160') }
  given!(:s5) { create(:screen, state: 'ready_to_coat') }
  given!(:s6) { create(:screen, frame_type: 'Static') }

  context 'when logged in as a user' do

    include_context 'logged_in_as_user'

    context 'screen status & lookup' do
      before(:each) do
        visit status_screens_path
      end

      scenario 'can advance success state and closes modal' do
        scan_barcode('screen-id', s1.id)
        click_link 'Removed from production'
        sleep 1
        expect(page).to have_content "Reclaimed"
        expect(page).to have_content "Current State is Ready To Reclaim"
        expect(page).to have_content "Screen state was successfully updated"
        sleep 4.5
        expect(page).not_to have_content "Current State is Ready To Reclaim"
      end

      scenario 'can advance broken state', retry: 3 do
        scan_barcode('screen-id', s1.id)
        sleep 1
        click_link 'Broke'
        sleep 1.0
        select user.email, from: "user_id"
        #select Screen::SCREEN_BREAK_REASONS.last, from: "reason"
        select "Heating Cabinet Failure", from: "reason"
        #this should pass. new reason for failure

        click_button 'Confirm Break'
        expect(page).to have_content "Mesh"
        expect(page).to have_content "Current State is Broken"
        expect(page).to have_content "Screen state was successfully updated"
      end

      scenario 'can advance bad_prep state', retry: 3 do
        scan_barcode('screen-id', s1.id)
        click_link 'Bad Prep'
        sleep 1.5
        select user.email, from: "user_id"
        select Screen::SCREEN_BAD_PREP_REASONS.last, from: "reason"
        click_button 'Confirm Bad Prep'
        expect(page).to have_content "Reclaimed"
        expect(page).to have_content "Current State is Ready To Reclaim"
        expect(page).to have_content "Screen state was successfully updated"
      end

      scenario 'can transition a screen and still sort' do
        within(:xpath, "//table/tbody/tr[1]/td") do
          expect(page).to have_content('Roller')
        end
        scan_barcode('screen-id', s1.id)
        click_link 'Removed from production'
        sleep 4.5
        page.find('th.tablesorter-header').click
        page.find('th.tablesorter-header').click
        sleep 0.5
        within(:xpath, "//table/tbody/tr[1]/td") do
          expect(page).to have_content('Static')
        end
      end

      context 'can filter by a single field', filter: true do

        scenario 'can filter by only Frame Type' do
          visit status_screens_path
          within(".frame-filter") do
            sleep 1
            select2("Panel", from: 'Frame Type')
          end
          click_button 'Filter'
          expect(page).to have_content('Panel')
          expect(page).not_to have_content('Roller')
        end

        scenario 'can filter by only Mesh Type' do
          visit status_screens_path
          within(".mesh-filter") do
            sleep 1
            select2("160", from: 'Mesh Type')
          end
          click_button 'Filter'
          expect(page).to have_content('160')
          expect(page).not_to have_content('110')
        end

        scenario 'can filter by only Dimensions' do
          visit status_screens_path
          within(".dimensions-filter") do
            sleep 1
            select2("25x36", from: 'Dimensions')
          end
          click_button 'Filter'
          expect(page).to have_content('25x36')
          expect(page).not_to have_content('23x31')
        end

        scenario 'can filter by only State' do
          visit status_screens_path
          within(".state-filter") do
            sleep 1
            select2("Ready to coat", from: 'State')
          end
          click_button 'Filter'
          expect(page).to have_content('Ready To Coat')
          expect(page).not_to have_content('In Production')
        end
      end

      context 'can filter by multiple fields' do

        scenario 'can filter by two frame types' do
          visit status_screens_path
          within(".frame-filter") do
            sleep 1
            select2("Static", from: 'Frame Type')
            sleep 1
            select2("Panel", from: 'Frame Type')
          end
          click_button 'Filter'
          expect(page).to have_content('Panel')
          expect(page).to have_content('Static')
          expect(page).not_to have_content('Roller')
        end
      end

      scenario 'can filter and unfilter', current: true do
        visit status_screens_path
        within(".frame-filter") do
          sleep 1
          select2("Static", from: 'Frame Type')
          sleep 1
          select2("Roller", from: 'Frame Type')
        end
        click_button 'Filter'
        expect(page).to have_content('Roller')
        expect(page).to have_content('Static')
        expect(page).not_to have_content('Panel')

        page.first(".select2-search-choice-close").click
        page.first(".select2-search-choice-close").click
        click_button 'Filter'
        expect(page).to have_content('Static')
        expect(page).to have_content('Roller')
      end

      scenario 'can sort columns', story_691: true do
        visit status_screens_path
        within(:xpath, "//table/tbody/tr[1]/td") do
          expect(page).to have_content('Roller')
        end
        find('th.tablesorter-header').click
        find('th.tablesorter-header').click
        sleep 0.5
        within(:xpath, "//table/tbody/tr[1]/td") do
          expect(page).to have_content('Static')
        end
      end
    end

    context 'fast scanning', story_546: true do
      let!(:initial_state) { s1.state }

      before(:each) do
        visit fast_scan_screens_path
      end

      scenario 'selecting an expected current state updates expected transitions' do
        select2 "coated_and_drying", from: 'Expected Current State'
        sleep 0.5
        select2 "dry", from: 'Expected Transition'
      end

      scenario 'can advance a screen state' do
        select2 "in_production", from: 'Expected Current State'
        sleep 0.5
        select2 "removed_from_production", from: 'Expected Transition'
        sleep 0.5
        scan_barcode('screen_id', s1.id)
        sleep 0.5
        expect(page).to have_content "Hooray! Screen state was successfully updated"
      end

      scenario 'properly raises error upon invalid state change attempt' do
        select2 "new", from: 'Expected Current State'
        sleep 0.5
        select2 "broke", from: 'Expected Transition'
        scan_barcode('screen_id', s1.id)
        sleep 0.5
        expect(page).to have_content "Screen was not in the expected state"
      end

      scenario 'can scan and advance two screens back to back without needing to click screen' do
        select2 "in_production", from: 'Expected Current State'
        sleep 0.5
        select2 "removed_from_production", from: 'Expected Transition'
        sleep 0.5
        scan_barcode('screen_id', s1.id)
        sleep 4
        # TODO: Ricky look into how to confirm field was reset
        scan_barcode('screen_id', s2.id)
        expect(page).to have_content "Hooray! Screen state was successfully updated"
      end

      scenario 'can fix bad screen state', bad_screen_state: true do
        click_link "Fix bad screen state"
        sleep 0.5

        scan_barcode('bad_screen_id', s1.id)
        sleep 0.5
        select2 "in_production", from: 'What state should it be in?'
        fill_in 'Which role(s) neglected to update the screen properly?', with: 'ricky'

        click_button 'Submit'

        expect(page).to have_content "Screen ##{s1.id}'s state has been adjusted"
        expect(s1.reload.state).to eq 'in_production'
        expect(s1.activities.last.parameters).to eq(
          'responsible' => "ricky",
          'state_from'  => initial_state,
          'state_to'    => 'in_production'
        )
      end
    end

  end
end

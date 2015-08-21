require 'spec_helper'

feature 'Imprints' do

  given(:print) { create(:print) }
  given(:order) { create(:order) }

  context "as an admin" do
    include_context 'logged_in_as_admin'

    given!(:machine) { create(:machine) }

    scenario 'I can search imprints', story_460: true do
      visit imprints_path
      fill_in 'q[text]', with: print.name
      click_button 'Search'
      expect(Sunspot.session).to be_a_search_for(Imprint)
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
          select print.type, from: 'Type'
          select machine.name, from: 'Machine'
          fill_in 'Estimated Time in Hours', with: 3
          fill_in 'Machine Print Count', with: 7
          choose('Yes')
        end
      end
      click_button 'Create Order'
      sleep 1
      within('.imprints') do
        click_link "Show Full Details"
      end
      expect(page).to have_content 'This Imprint Requires Signoff'
    end
  end

  context 'as a user' do
    include_context 'logged_in_as_user'

    given!(:admin) { create(:admin) }

    scenario "I can transition an imprint state", js: true, story_694: true do
      visit imprint_path(print)
      expect(page).to have_content "Current State is Pending Approval"
      click_button 'Approve'

      expect(page).to have_content "Current State is Ready To Print"
      expect(print.reload.state).to eq 'ready_to_print'
    end

    context 'when there is a CRM imprint', story_864: true do
      given!(:crm_imprint) { create(:crm_imprint) }

      background do
        print.update_attributes! softwear_crm_id: crm_imprint.id
      end

      context 'and something goes wrong in CRM' do
        background do
          allow(Crm::Imprint).to receive(:find).and_raise "Oh no - we broke it"
        end

        scenario 'I am informed of this error' do
          visit imprint_path(print)
          expect(page).to have_content 'Oh no - we broke it'
        end
      end

      context 'with proofs' do
        given!(:crm_imprint) { create(:crm_imprint_with_proofs) }

        context 'that are rejected' do
          background do
            allow_any_instance_of(Crm::Proof).to receive(:status).and_return 'Rejected'
          end

          scenario 'an alert box tells me that they are rejected' do
            visit imprint_path(print)
            expect(page).to have_content "This proof was rejected."
          end
        end

        context 'that are not approved' do
          scenario 'an alert box tells me that they are not yet approved' do
            visit imprint_path(print)
            expect(page).to have_content "This proof is not yet approved."
          end
        end
      end

      context 'without proofs' do
        given!(:crm_imprint) { create(:crm_imprint) }

        scenario 'an alert box tells me there are no proofs' do
          visit imprint_path(print)
          expect(page).to have_content "There are no proofs associated with this imprint in SoftWEAR-CRM."
        end
      end
    end

    context 'when an imprint requires manager sign off', js: true do

      given(:imprint) { create(:print, type: 'ScreenPrint', require_manager_signoff: true) }
      before(:each) { imprint.update_column(:state, :pending_production_manager_approval) }

      scenario "When an imprint requires manager sign off, the manager needs to enter their password" do
        visit imprint_path(imprint)
        expect(page).to have_content "Current State is Pending Production Manager Approval"
        select2_tag(admin.full_name, from: "approved by")
        fill_in :manager_password, with: '2_1337_4_u'
        click_button "Production manager approved"
        expect(page).to have_content "Current State is In Production"
      end
    end
  end

end

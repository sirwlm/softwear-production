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
      within('.production_trains') do
        click_link "Show Full Details"
      end
      sleep(1)
      expect(page).to have_content 'This Imprint Requires Signoff'
    end
  end

  context 'as a user' do
    include_context 'logged_in_as_user'
    given!(:admin) { create(:admin) }
    background(:each) { print.job = order.jobs.first }
  
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

      context 'with proofs', js: true, current: true do
        given!(:crm_imprint) { create(:crm_imprint_with_proofs) }
        background do
          allow_any_instance_of(Crm::Proof).to receive(:state).and_return 'not_ready'
        end

        context 'that are rejected' do
          background do
            allow_any_instance_of(Crm::Proof).to receive(:state).and_return 'customer_rejected'
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
  end
end

require 'spec_helper'

feature 'Shipment Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'

    given(:manager) { create(:admin) }
    given(:shipment_train) { create(:shipment_train, shipment_holder: order) }
    given(:order) { create(:order) }

    scenario 'The trains successful stations are Labels Staged, Labels Printed', story_868: true do

      visit show_train_path(:shipment_train, shipment_train)

      expect(page).to have_css('.alert-info', text: 'Pending Packing')
      within('.train-category-success') do
        click_button 'Packed'
        sleep(1.5)
      end

      expect(page).to have_css('.alert-info', text: 'Pending Shipment')
      select_from_select2 ShipmentTrain::CARRIERS.last, finder: :first
      select_from_select2 manager.full_name, finder: :last
      within('.train-category-success') do
        fill_in "shipment_train_tracking", with: "12345718XO"
        fill_in "shipment_train_service", with: "First Class"
        find("#shipment_train_shipped_at").click
        find("#shipment_train_shipped_at").native.send_keys(:enter)
        click_button 'Shipped'
        sleep(1.5)
      end

      expect(page).to have_css('.alert-info', text: 'Shipped')
      within('.train-category-success') do
        expect(page).to have_no_selector('button')
      end

    end

    scenario 'I can add a shipment train to an order' do
      visit order_path(order)
      within("#order-post-production .post_production_trains") do
        click_link("+")
      end
      sleep(1)
      select("ShipmentTrain", from: 'train_class')
      click_button("Create Train")
      expect(page).to have_content "Shipment Train"
    end

  end
end

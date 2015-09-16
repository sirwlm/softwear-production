require 'spec_helper'

feature 'Store Delivery Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
    
    given(:manager) { create(:admin) }
    given(:store_delivery_train) { create(:store_delivery_train) }
    given(:order) { create(:order) }

    scenario 'The trains successful stations are ', story_868: true do
      
      visit show_train_path(:store_delivery_train, store_delivery_train)
      
      expect(page).to have_css('.alert-info', text: 'Pending Packing')
      within('.train-category-success') do 
        click_button 'Packed'
        sleep(1.5)
      end

      expect(page).to have_css('.alert-info', text: 'Ready For Delivery')
      within('.train-category-success') do 
        select(manager.full_name, from: "store_delivery_train_delivered_by_id" )
        select(StoreDeliveryTrain::STORES.last, from: "store_delivery_train_store_name" )
        click_button 'Out for delivery'
        sleep(1.5)
      end

      expect(page).to have_css('.alert-info', text: 'Out For Delivery')
      within('.train-category-success') do 
        click_button 'Delivered'
        sleep(1.5)
      end

      expect(page).to have_css('.alert-info', text: 'Delivered')
      within('.train-category-success') do 
        expect(page).to have_no_selector('button')
      end      

    end

    scenario 'I can add a store delivery train to an order' do 
      visit order_path(order)
      within("#order-post-production .post_production_trains") do 
        click_link("+")
      end
      sleep(1)
      select("StoreDeliveryTrain", from: 'train_class')
      click_button("Create Train")
      expect(page).to have_content "Store delivery train"
    end

  end
end

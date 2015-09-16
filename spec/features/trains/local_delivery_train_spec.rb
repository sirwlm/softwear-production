require 'spec_helper'

feature 'Local Delivery Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
    
    given(:manager) { create(:admin) }
    given(:local_delivery_train) { create(:local_delivery_train) }
    given(:order) { create(:order) }

    scenario 'The trains successful stations are Pending Packing, Ready for Delivery, Out For Delivery, Delivered', story_868: true do
      
      visit show_train_path(:local_delivery_train, local_delivery_train)
      
      expect(page).to have_css('.alert-info', text: 'Pending Packing')
      success_transition :packed

      expect(page).to have_css('.alert-info', text: 'Ready For Delivery')
      select(manager.full_name, from: "local_delivery_train_delivered_by_id" )
      success_transition :out_for_delivery

      expect(page).to have_css('.alert-info', text: 'Out For Delivery')
      find('#local_delivery_train_delivered_to_name').set('Ricky Bobby')
      success_transition :delivered
      
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
      select("LocalDeliveryTrain", from: 'train_class')
      click_button("Create Train")
      expect(page).to have_content "Local delivery train"
    end

  end
end

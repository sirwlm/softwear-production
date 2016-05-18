require 'spec_helper'

feature 'CustomInkColorTrains' do
  include_context 'logged_in_as_user'

  context 'When adding preproduction trains to orders' do
    given!(:order) { create(:order) }
    scenario 'I can add a CustomInkColorTrain', js: true do
      visit order_path(order)
      sleep 1
      within("#order-pre-production .pre_production_trains") do
        click_link("+")
      end
      select("CustomInkColorTrain", from: "train_class")
      click_button("Create Train")
      expect(page).to have_content "Custom Ink Color Train"
    end
  end

end

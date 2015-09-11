require 'spec_helper'

feature 'Imprintable Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
    
    given(:imprintable_train) { create(:imprintable_train) }

    scenario 'I can order all pieces, then specify a supplier, supplier_location, expected_arrival', story_868: true do
      
      visit show_train_path(:imprintable_train, imprintable_train)
      
    end
    
  end
end

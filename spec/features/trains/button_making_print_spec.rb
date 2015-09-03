require 'spec_helper'

feature 'Prints' do


  context "as an admin" do
    include_context 'logged_in_as_admin'
 
    scenario "I can create an order with a print"

    scenario "I can transition a print state", js: true, story_909: true
    
    context 'when a print requires manager sign off', js: trued

  end

end

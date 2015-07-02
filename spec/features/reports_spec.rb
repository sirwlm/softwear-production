require 'spec_helper'

feature 'Reports' do
  
  context 'as an administrator' do 
    context 'I can view reports about imprints' do
      let!(:machine_1) { create(:machine) }
      let!(:machine_2) { create(:machine) }

      before(:each) {
       allow_any_instance_of(Machine).to receive(:imprints).and_return (
        double( 
        "where" => 
          [
            build(:imprint, count: 100, completed_at: nil),
            build(:imprint, count: 50, completed_at: '2015-06-26 1:00:00'),
            build(:imprint, count: 1, completed_at: '2015-06-27')
          ]
        )
       )
      }

      scenario 'I can see how many prints were done on each machine for a given time period' do        
        visit root_path
        click_link 'Reports'
        click_link 'Imprint Count'
        fill_in "Start Date", with: "2015-06-26" 
        fill_in "End Date", with: "2015-06-28"
        click_button 'Run Report'
        
        expect(page).to have_selector('th', text: machine_1.name)
        expect(page).to have_selector('td', text: '2015-06-26')
        expect(page).to have_selector('td', text: '51')


        # expect(page).to have_content :th, content:  "2015-06-28"
        # check for a td with the right number for machine A
        # check for a td with the right number for machine b
        
        # expect(page).to have_content :th, content:  "2015-06-28"
        # check for a td with the right number for machine A
        # check for a td with the right number for machine b
      end 
    end
  end
  
  context 'as a user' do 
    scenario "I do not see a button for reports"
    
    scenario "If I visit a report directly, I'm redirected to the homepage"

  end
  


  include_context 'logged_in_as_user'
  
  

end


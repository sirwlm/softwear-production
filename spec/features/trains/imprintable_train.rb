require 'spec_helper'

feature 'Imprintable Train' do

  context "as an admin", js: true do
    include_context 'logged_in_as_admin'
    
    given(:imprintable_train) { create(:imprintable_train) }

    scenario 'I can order all pieces, then specify a supplier, supplier_location, expected_arrival', story_868: true do
      
      visit show_train_path(:imprintable_train, imprintable_train)
      
    end
    
  end

  context 'not logged in as an admin', non_admin: true, js: true do
    include_context 'logged_in_as_user'

    given!(:order) { create(:order) }
    given!(:imprintable_train) { create(:imprintable_train, job: order.jobs.first) }
    
    background :each do
      allow_any_instance_of(SunspotMatchers::SunspotSearchSpy).to receive(:results) { 
        Kaminari.paginate_array([imprintable_train]).page(1).per(10) }   
      
      visit pre_production_dashboard_path
      expect(imprintable_train.activities.count).to eq(0) 
      
      within("#imprintable-train-#{imprintable_train.id}") do
        first('a').click
      end
      sleep 0.5
      
      within(".imprintable-train-panel") do
        first('a').click
      end
      sleep 0.5 
    end

    context 'given an imprintable train with an expected_arrival_date' do

      scenario 'I can change the expected_arrival_date in the show and see the new change immediately' do
        arrival_date = imprintable_train.expected_arrival_date
        PublicActivity.with_tracking do
          expect(arrival_date.strftime("%a, %d %b %Y")).to eq("#{Date.today.strftime('%a, %d %b %Y')}") 
          within(".modal-body") do
            find("span[title='Expected arrival date'][data-type='date']").click
          end
          sleep 0.5 

          within('tbody') do
            # will always pick tomorrows date, as expected is currently today.
            find("td[class='day']", text: "#{Date.tomorrow.day}").click
          end
          sleep 0.5

          within('.editable-buttons')do
            find("button[type='submit']").click
          end
          sleep 0.5 
        end # end PublicActivity tracking

        expect(page).to have_content(Date.tomorrow.strftime('%m/%d/%Y'))
        # checks for created activity as well
        expect(imprintable_train.reload.activities.count).to eq(1)

        arrival_date = imprintable_train.expected_arrival_date
        expect(arrival_date.strftime("%a, %d %b %Y")).to eq("#{Date.tomorrow.strftime('%a, %d %b %Y')}")
      end
    end

    context 'given an imprintable train with a location set' do
      scenario 'I can change the location of the train on the show and see the new change immediately' do
        PublicActivity.with_tracking do
          within('.modal-body') do
            find("span[data-name='location']").click
          end
          sleep 0.5
          
          within('.editable-input') do
            find("input[type='text']").set("No longer here!")
          end
          sleep 0.5
          
          within('.editable-buttons')do
            find("button[type='submit']").click
          end
          sleep 0.5 
          expect(page).to have_content(imprintable_train.reload.location)

        end # end PublicActivity tracking
      end
    end
  end
end

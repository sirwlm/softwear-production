require 'spec_helper'

describe 'reports/imprint_count.html.erb' do

  context 'There is a start date and an end date' do
    include_context "logged_in_as_admin"
    
    let!(:machine) { create(:machine) }

    let(:report_hash) {
      {
        start_date: '2015-06-26',
        end_date: '2015-06-28', 
        machines: {
          machine.name => {
            '2015-06-26' => '51',
            '2015-06-27' => '75',
            '2015-06-28' => '0',
          }
        }
      }
    }

    before(:each) do 
      assign(:report_data, report_hash)
      render template: 'reports/imprint_count', locals: { current_user: admin }
    end
    
    it 'shows the start date and the end date' do 
      expect(rendered).to have_content "Start Date: 2015-06-26"
      expect(rendered).to have_content "End Date: 2015-06-28"
    end

    it 'has a table with a row for every date between and including the start_date and end_date' do 
      (report_hash[:start_date]..report_hash[:end_date]).each do |date|
        expect(rendered).to have_css 'td', text: date
      end
    end
    
    it 'has a column for every machine that exists' do 
      expect(rendered).to have_css 'th', text: machine.name
    end
   
    it 'each column+row is the total completed imprints on a machine for a date' do 
      expect(rendered).to have_css 'td', text: '51'
      expect(rendered).to have_css 'td', text: '75'
      expect(rendered).to have_css 'td', text: '0'
    end

  end

end

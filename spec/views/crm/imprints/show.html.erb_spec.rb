require 'spec_helper'

describe 'crm/imprints/show.html.erb', imprint_spec: true, story_200: true do
  let!(:imprint) { build_stubbed :imprint }

  it 'displays print location, imprint method, and name numbers' do
    render partial: 'crm/imprints/show.html.erb', locals: { imprint: imprint }
    
    expect(rendered).to have_content imprint.print_location
    expect(rendered).to have_content imprint.imprint_method
    expect(rendered).to have_content imprint.name
    expect(rendered).to have_content imprint.number
  end
end

require 'spec_helper'

describe 'machines/scheduled.json.jbuilder', machine_spec: true, story_113: true do
  include_context 'devise_view_setup'
  let!(:machine) { create(:machine) }

  it "extracts all of the information relating to the imprints scheduled to machine's into a json object", pending: 'need to figure this out' do
    expect(false).to eq(true)      
  end
end

require 'spec_helper'

describe 'machines/index.json.jbuilder', machine_spec: true, story_113: true do
  include_context 'devise_view_setup'
  let!(:machine) { create(:machine) }


  it "extracts each machine's id and url into a json object", pending: 'need to figure this out' do
    expect(false).to eq(true)
  end
end

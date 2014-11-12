require 'spec_helper'

describe 'machines/index.json.jbuilder', machine_spec: true, story_113: true do
  let!(:machines) { [create(:machine)] }

  before(:each) do
    assign(:machines, machines)
    render template: '/machines/index', format: 'json', handler: 'jbuilder'
  end

  it 'extracts machine id and machine_url' do
    # body = JSON.parse(response.body)
    # body.should include('id')
    # body.should include('created_at')
    # body.should include('updated_at')
    # groups = body['group']
    # groups.should have(2).items
    # groups.all? {|group| group.key?('customers_count')}.should be_true
    # groups.any? {|group| group.key?('customer_ids')}.should be_false
  # end
  end
end
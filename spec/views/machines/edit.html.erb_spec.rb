require 'spec_helper'

describe 'machines/edit.html.erb', machine_spec: true, story_113: true do
  let!(:machine) { create(:machine) }

  before(:each) do
    assign(:machine, machine)
    render
  end
  it 'renders the form to be edited' do
    expect(rendered).to render_template(partial: '_form')
  end
end

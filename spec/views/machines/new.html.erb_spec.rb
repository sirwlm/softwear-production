require 'spec_helper'

describe 'machines/new.html.erb', machine_spec: true, story_113: true do
  include_context 'devise_view_setup'
  let!(:machine) { create(:machine) }

  before(:each) do
    assign(:machine, machine)
    render
  end
  it 'renders a new form' do
    expect(rendered).to render_template(partial: '_form')
  end
end

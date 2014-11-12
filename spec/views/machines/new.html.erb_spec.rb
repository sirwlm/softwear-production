require 'spec_helper'

describe 'machines/new.html.erb', machine_spec: true, story_113: true do
  let!(:machine) { create(:machine) }

  before(:each) do
    assign(:machine, machine)
    render
  end
  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end
end

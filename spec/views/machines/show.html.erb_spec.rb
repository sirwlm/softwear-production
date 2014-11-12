require 'spec_helper'

describe 'machines/show.html.erb', machine_spec: true, story_113: true do
  let!(:machine) { create(:machine) }

  before(:each) do
    assign(:machine, machine)
    render
  end
  it 'render _form.html.erb' do
    expect(rendered).to have_css('h1.heading', text: "#{machine.name} Production Schedule")
    expect(rendered).to have_css("div#machine-calendar[data-machine='#{machine.id}']")
  end
end

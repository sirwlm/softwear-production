require 'spec_helper'

describe 'machines/index.html.erb', machine_spec: true, story_113: true do
  let!(:machines) { [create(:machine)] }

  before(:each) do
    assign(:machines, machines)
    render
  end
  it 'has a table of machines' do
    expect(rendered).to have_css('th', text: 'ID')
    expect(rendered).to have_css('th', text: 'Name')
    expect(rendered).to have_css('th', text: 'Actions')
    expect(rendered).to have_css('td', text: machines.first.name)
    expect(rendered).to have_css('td', text: machines.first.id)
  end

  it 'has links for actions' do
    expect(rendered).to have_css('a', text: 'Show')
    expect(rendered).to have_css('a', text: 'Edit')
    expect(rendered).to have_css('a', text: 'Destroy')
    expect(rendered).to have_css("a[href='/machines/#{machines.first.id}']")
    expect(rendered).to have_css("a[href='#{edit_machine_path(machines.first.id)}']")
    expect(rendered).to have_css("a[href='/machines/#{machines.first.id}'][data-method='delete']")
  end

  it 'has a new machine link' do
    expect(rendered).to have_css('a', text: 'New Machine')
    expect(rendered).to have_css("a[href='#{new_machine_path}']")
  end
end

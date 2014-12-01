require 'spec_helper'

describe 'machines/_form.html.erb', machine_spec: true, story_113: true do
  include_context 'devise_view_setup'
  let!(:machine) { create(:machine) }

  before(:each) do
    render partial: 'machines/form', locals: { machine: machine }
  end

  it 'has a field for name and a submit link' do
    expect(rendered).to have_css('input#machine_name')
    expect(rendered).to have_css("input.btn[type='submit']")
  end
end
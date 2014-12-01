require 'spec_helper'

describe 'imprints/edit.html.erb', imprint_spec: true do
  include_context 'devise_view_setup'

  before(:each) do
    assign(:machines, [])
    @imprint = assign(:imprint, Imprint.create!())
    render
  end

  it 'renders the edit imprint form' do
    assert_select 'form[action=?][method=?]', imprint_path(@imprint), 'post' do
    end
  end
end

require 'spec_helper'

describe 'imprints/new.html.erb', imprint_spec: true do
  include_context 'devise_view_setup'

  before(:each) do
    assign(:imprint, Imprint.new)
    assign(:machines, [])
    render
  end

  it 'renders new imprint form' do
    assert_select 'form[action=?][method=?]', imprints_path, 'post' do
    end
  end
end

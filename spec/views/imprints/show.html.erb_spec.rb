require 'spec_helper'

describe 'imprints/show.html.erb', imprint_spec: true do
  include_context 'devise_view_setup'

  before(:each) do
    @imprint = assign(:imprint, Imprint.create!())
    render
  end

  it 'renders attributes in <p>' do
    # TODO: this view doesn't have anything in it....
  end
end

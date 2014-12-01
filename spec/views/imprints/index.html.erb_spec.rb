require 'spec_helper'

describe 'imprints/index.html.erb', imprint_spec: true do
  include_context 'devise_view_setup'

  # TODO: imprint factory
  before(:each) do
    assign(:imprints, [
      Imprint.create!,
      Imprint.create!
    ])
    render
  end

  it 'renders a list of imprints' do
    render
  end
end

require 'spec_helper'

RSpec.describe "imprints/show", :type => :view do
  before(:each) do
    @imprint = assign(:imprint, Imprint.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end

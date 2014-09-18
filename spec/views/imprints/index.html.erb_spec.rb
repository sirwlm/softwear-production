require 'spec_helper'

RSpec.describe "imprints/index", :type => :view do
  before(:each) do
    assign(:imprints, [
      Imprint.create!(),
      Imprint.create!()
    ])
  end

  it "renders a list of imprints" do
    render
  end
end

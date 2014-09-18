require 'spec_helper'

RSpec.describe "machines/index", :type => :view do
  before(:each) do
    assign(:machines, [
      Machine.create!(),
      Machine.create!()
    ])
  end

  it "renders a list of machines" do
    render
  end
end

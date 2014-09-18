require 'spec_helper'

RSpec.describe "machines/show", :type => :view do
  before(:each) do
    @machine = assign(:machine, Machine.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end

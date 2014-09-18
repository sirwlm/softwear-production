require 'spec_helper'

RSpec.describe "machines/new", :type => :view do
  before(:each) do
    assign(:machine, Machine.new())
  end

  it "renders new machine form" do
    render

    assert_select "form[action=?][method=?]", machines_path, "post" do
    end
  end
end

require 'spec_helper'

RSpec.describe "machines/edit", :type => :view do
  before(:each) do
    @machine = assign(:machine, Machine.create!())
  end

  it "renders the edit machine form" do
    render

    assert_select "form[action=?][method=?]", machine_path(@machine), "post" do
    end
  end
end

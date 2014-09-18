require 'spec_helper'

RSpec.describe "imprints/new", :type => :view do
  before(:each) do
    assign(:imprint, Imprint.new())
  end

  it "renders new imprint form" do
    render

    assert_select "form[action=?][method=?]", imprints_path, "post" do
    end
  end
end

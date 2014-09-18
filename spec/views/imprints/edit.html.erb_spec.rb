require 'spec_helper'

RSpec.describe "imprints/edit", :type => :view do
  before(:each) do
    @imprint = assign(:imprint, Imprint.create!())
  end

  it "renders the edit imprint form" do
    render

    assert_select "form[action=?][method=?]", imprint_path(@imprint), "post" do
    end
  end
end

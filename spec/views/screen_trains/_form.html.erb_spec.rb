require 'spec_helper'

describe "screen_trains/_form", type: :view do

  let(:screen_train) { create(:screen_train) }

  it 'has a due_at, an assigned_to, notes, garment_material, garment_weight'\
     ' artwork_location, print_type, and multi-select imprints' do
    render "screen_trains/form", screen_train: screen_train 
    expect(rendered).to have_css("input#due_at")
    expect(rendered).to have_css("select#assigned_to")
    expect(rendered).to have_css("textarea#notes")
    expect(rendered).to have_css("input#garment_material")
    expect(rendered).to have_css("input#garment_weight")
    expect(rendered).to have_css("input#artwork_location")
    expect(rendered).to have_css("input#print_type")
    expect(rendered).to have_css("select#imprints")
  end

  context 'the state is the initial state' do 
    it 'has a new separation boolean'
  end
end

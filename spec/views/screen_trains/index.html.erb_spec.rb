require 'spec_helper'

describe "screen_trains/index", type: :view do
  let(:screen_train) { create(:screen_train) }
  before(:each) { assign(:screen_trains,  Kaminari.paginate_array([screen_train]).page(1).per(10)) }

  it "has a table with order, imprints, order deadline, separation deadline"\
          " state, new?, FBA?, artwork_location, print_type, machine, quantity, garment weight"\
          " garment_material, comments, screen_requests, assigned_Screensi, assigned_to"\
          " signed_off_by", pending: true do 
    render
    expect(rendered).to have_css(:td, text: screen_train.order.name)
    expect(rendered).to have_css('dd.screen-train-count', text: '0')
    expect(rendered).to have_css('dd.screen-train-imprints')
    expect(rendered).to have_css('dd.screen-train-new-separation', text: 'yes')
    expect(rendered).to have_css('dd.screen-train-fba', text: 'no')
    expect(rendered).to have_css('dd.screen-train-artwork-location')
    expect(rendered).to have_css('dd.screen-train-print-type', text: 'spot') 
    expect(rendered).to have_css(:td, text: screen_train.state)
    expect(rendered).to have_css(:td, text: screen_train.due_at)
    expect(rendered).to have_css(:td, text: screen_train.order.deadline)
    expect(rendered).to have_css(:td, text: 'unassigned')
  end

end

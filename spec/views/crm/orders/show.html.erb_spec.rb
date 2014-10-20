require 'spec_helper'

describe 'crm/orders/show.html.erb', order_spec: true, story_200: true do
  let!(:order) { build_stubbed :order }

  it 'shows the order name, email, company and in_hand_by' do
    assign(:order, order)
    expect(rendered).to have_content order.name
    expect(rendered).to have_content order.email
    expect(rendered).to have_content order.company
    expect(rendered).to have_content order.in_hand_by
  end
end

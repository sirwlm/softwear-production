require 'spec_helper'

describe 'crm/orders/index.html.erb', order_spec: true, story_200: true do
  let!(:order1) { build_stubbed :order }
  let!(:order2) { build_stubbed :order }
  let!(:order3) { build_stubbed :order }

  it 'displays the names of all orders' do
    assign(:orders, [order1, order2, order3])
    render
    [order1, order2, order3].each do |order|
      expect(rendered).to have_content order.name
    end
  end
end
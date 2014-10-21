require 'spec_helper'

describe Order do
  it { is_expected.to validate_presence_of :softwear_crm_id }

  describe '#crm_order' do
    let!(:crm_order) { create :crm_order }
    let!(:order) { Order.create(softwear_crm_id: crm_order.id) }
    
    it 'returns the crm order associated with #softwear_crm_id' do
      expect(order).to respond_to :crm_order
      expect(order.crm_order).to eq crm_order
    end
  end
end

require 'spec_helper'

describe Imprint, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:machine) }
  end



end

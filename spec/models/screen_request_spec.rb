require 'spec_helper'

describe ScreenRequest, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to :screen }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :frame }
    it { is_expected.to validate_presence_of :mesh }
    it { is_expected.to validate_presence_of :size }
    it { is_expected.to validate_presence_of :lpi }
    it { is_expected.to validate_presence_of :primary }
  end
  
end

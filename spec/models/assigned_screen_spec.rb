require 'spec_helper'

describe AssignedScreen, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to :screen }
    it { is_expected.to belong_to :screen_train }
    it { is_expected.to belong_to :screen_request }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :screen }
    it { is_expected.to validate_presence_of :screen_train }
    it { is_expected.to validate_presence_of :screen_request }
  end

  describe '#is_doubled_up?' do 
    it 'returns true if not blank'
  end
  
end

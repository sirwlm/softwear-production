require 'spec_helper'

describe ScreenRequest, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to :screen_train }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :screen_train }
    it { is_expected.to validate_presence_of :frame_type } 
    it { is_expected.to validate_presence_of :mesh_type }
    it { is_expected.to validate_presence_of :dimensions }
    it { is_expected.to validate_presence_of :lpi }
    it { is_expected.to validate_presence_of :ink }
  end
 
  describe 'given a screen_request exists on the order that shares the color'\
            'and is primary' do 
    it 'creating a new primary screen_request will make the other primary false'
  end


end

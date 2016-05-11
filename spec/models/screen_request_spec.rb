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
    it { is_expected.to validate_presence_of :ink }
  end

end

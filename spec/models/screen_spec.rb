require 'spec_helper'

describe Screen, type: :model do

  describe 'Relationships' do
    it { is_expected.to have_many(:assigned_screens) }
    it { is_expected.to have_many(:imprints).through(:assigned_screens) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :frame_type }
    it { is_expected.to validate_presence_of :state }
    it { is_expected.to validate_presence_of :dimensions }
  end


end

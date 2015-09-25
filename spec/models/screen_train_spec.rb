require 'spec_helper'

describe ScreenTrain, type: :model do

  describe 'Relationships' do
    it { is_expected.to belong_to :order }
    it { is_expected.to have_many :assigned_screens }
    it { is_expected.to have_many(:screens).through(:assigned_screens) }
    it { is_expected.to have_many(:imprints) }
    it { is_expected.to have_many(:machines).through(:imprints) }
    it { is_expected.to have_many(:screen_requests) }
    it { is_expected.to have_many(:jobs).through(:imprints) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :order }
  end
  
  describe '#proof_reuest_data_complete?' do 
    it 'returns true if the required fields are filled in'
  end

  describe '#fba?' do 
  end

end

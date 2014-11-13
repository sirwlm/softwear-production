require 'spec_helper'

describe Machine, machine_spec: true, story_113: true do
  describe 'Relationships' do
    it { is_expected.to have_many(:imprints) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end

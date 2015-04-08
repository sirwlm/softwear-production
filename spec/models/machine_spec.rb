require 'spec_helper'

describe Machine, machine_spec: true, story_113: true, story_110: true do
  describe 'Relationships' do
    it { is_expected.to have_many(:imprints) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }

    context 'if scheduled? is true' do
      before { allow(subject).to receive(:scheduled?).and_return(true) }
      it { is_expected.to_not validate_presence_of(:imprints).with_message('all imprints must be scheduled to be assigned a machine') }
    end

    context 'if scheduled? is false' do
      before { allow(subject).to receive(:scheduled?).and_return(false) }
      it { is_expected.to_not validate_presence_of(:imprints) }
    end

    context 'when color is equal to the "imprint complete" color', story_480: true do
      before { allow(subject).to receive(:color).and_return '#cccccc' }
      it { is_expected.to_not be_valid }
    end

    context 'when color is equal to the "unapproved imprint" color', story_486: true do
      before { allow(subject).to receive(:color).and_return '#ffffff' }
      it { is_expected.to_not be_valid }
    end
  end
end

require 'spec_helper'

describe Imprint, imprint_spec: true, story_110: true do
  describe 'Scopes' do
    describe 'scheduled' do
      let!(:imprint_1) { create(:imprint, scheduled_at: '2014-01-01', estimated_time: 2.0, machine: build_stubbed(:machine))}
      let!(:imprint_2) { create(:imprint) }
      it 'only includes scheduled imprints' do
        expect(Imprint.scheduled.where(scheduled_at: nil)).to eq []
      end
    end
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:machine) }
  end

  describe 'Validations' do
    context 'if scheduled? is true' do
      before { allow(subject).to receive(:scheduled?).and_return(true) }
      it { is_expected.to validate_presence_of(:machine).with_message('must be selected in order to schedule a print') }
    end

    context 'if scheduled? is false' do
      before { allow(subject).to receive(:scheduled?).and_return(false) }
      it { is_expected.to_not validate_presence_of(:machine) }
    end
  end

  describe '#estimated_end_at' do
    let(:subject) { create(:imprint, scheduled_at: '2014-01-01', estimated_time: 2.0, machine_id: create(:machine).id)}
    it 'returns the time ' do
      expect(subject.estimated_end_at).to eq('2014-01-01 02:00:00')
    end
  end

end

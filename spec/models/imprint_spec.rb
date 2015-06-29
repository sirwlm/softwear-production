require 'spec_helper'

describe Imprint, imprint_spec: true, story_110: true do
  describe 'searches', story_460: true do
    it { should have_searchable_field(:name) }
  end

  describe 'Machine Print Counts', current: true do

  end

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
    
    it { is_expected.to validate_presence_of(:count) }
    it { is_expected.not_to allow_value(0, -1).for(:count) }
    
    context 'if scheduled? is true' do
      before { allow(subject).to receive(:scheduled?).and_return(true) }
      it { is_expected.to validate_presence_of(:machine).with_message('must be selected in order to schedule a print') }
    end

    context 'if scheduled? is false' do
      before { allow(subject).to receive(:scheduled?).and_return(false) }
      it { is_expected.to_not validate_presence_of(:machine) }
    end
  end

  describe 'Before save' do
    context 'when type is changed' do
      let(:print) { create(:print, state: :printed) }

      it 'resets state to pending_approval', story_694: true do
        print.type = 'ScreenPrint'
        print.save!

        expect(print.reload.state.to_sym).to eq :pending_approval
      end
    end
  end

  describe '#estimated_end_at' do
    let(:subject) { create(:imprint, scheduled_at: '2014-01-01', estimated_time: 2.0, machine_id: create(:machine).id)}
    it 'returns the time ' do
      expect(subject.estimated_end_at.strftime('%H:%M %Z')).to eq('02:00 EST')
    end
  end

  describe '#display', story_480: true do
    subject { create :imprint, name: 'Imprint Name', machine_id: nil, scheduled_at: nil }

    context 'when completed' do
      before { allow(subject).to receive(:completed?).and_return true }

      it 'equals (COMPLETE) name' do
        expect(subject.display).to eq '(UNAPPROVED) Imprint Name'
      end
    end

    context 'when not completed' do
      before { allow(subject).to receive(:completed?).and_return false }

      it 'equals name' do
        expect(subject.display).to eq '(UNAPPROVED) Imprint Name'
      end
    end
  end
end

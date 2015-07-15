require 'spec_helper'

describe Order do
  let(:order) { create(:order, jobs: [create(:job)]) }

  describe 'Relationships' do
    it { is_expected.to have_many :jobs }
    it { is_expected.to have_many(:imprints).through(:jobs) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :jobs }
    it { is_expected.to validate_presence_of :name }
  end

  describe '#complete?' do
    let(:completed_imprint) { double('Imprint', completed?: true) }
    let(:incomplete_imprint) { double('Imprint', completed?: false) }
    subject { order.complete? }

    context 'when all imprints are complete' do
      before { allow(order).to receive(:imprints).and_return [completed_imprint] * 3 }

      it { is_expected.to eq true }
    end
    context 'when some imprints are not complete' do
      before { allow(order).to receive(:imprints).and_return [completed_imprint, incomplete_imprint] }

      it { is_expected.to eq false }
    end
  end

  describe '#scheduled?' do
    let(:scheduled_imprint) { double('Imprint', scheduled?: true) }
    let(:unscheduled_imprint) { double('Imprint', scheduled?: false) }
    subject { order.scheduled? }

    context 'when all imprints are scheduled' do
      before { allow(order).to receive(:imprints).and_return [scheduled_imprint] * 3 }

      it { is_expected.to eq true }
    end
    context 'when some imprints are not scheduled' do
      before { allow(order).to receive(:imprints).and_return [scheduled_imprint, unscheduled_imprint] }

      it { is_expected.to eq false }
    end
  end

  context 'scheduling' do
    let!(:imprint_1) { double('Imprint', scheduled_at: 1.day.ago) }
    let!(:imprint_2) { double('Imprint', scheduled_at: 2.day.ago) }
    before do
      allow(order).to receive(:imprints).and_return [imprint_1, imprint_2]
      allow(order.imprints).to receive(:pluck) { |arg| order.imprints.map(&arg) }
    end

    describe '#earliest_scheduled_date' do
      subject { order.earliest_scheduled_date }

      it { is_expected.to eq imprint_2.scheduled_at }
    end

    describe '#latest_scheduled_date' do
      subject { order.latest_scheduled_date }

      it { is_expected.to eq imprint_1.scheduled_at }
    end
  end
end

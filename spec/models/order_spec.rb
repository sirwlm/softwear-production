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

    context 'when all imprints and trains are complete' do
      before(:each) do  
        allow(order).to receive(:imprint_state).and_return 'Printed'
        allow(order).to receive(:order_production_state).and_return 'Complete'
        allow(order).to receive(:jobs_production_state).and_return 'Complete'
      end

      it { is_expected.to eq true }
    end
    context 'when some imprints are not complete' do
      before { allow(order).to receive(:imprints).and_return [completed_imprint, incomplete_imprint] }

      it { is_expected.to eq false }
    end
  end

  describe 'fba_bagging_train' do
    let(:not_fba) { create(:order, fba: false, jobs: [create(:job)]) }

    context 'when fba is set to true on an order' do
      it 'is blank when fba is false' do
        expect(not_fba.fba_bagging_train).to be_blank
      end
      it 'is not blank after fba is set to true' do
        not_fba.fba = true
        not_fba.save
        expect(not_fba.fba_bagging_train).not_to be_blank
      end
    end

  end

  describe 'fba_label_train' do
    let(:not_fba) { create(:order, fba: false, jobs: [create(:job)]) }

    context 'when fba is set to true on an order' do
      it 'is blank when fba is false' do
        expect(not_fba.fba_label_train).to be_blank
      end
      it 'is not blank after fba is set to true' do
        not_fba.fba = true
        not_fba.save
        expect(not_fba.fba_label_train).not_to be_blank
      end
    end
  end

  describe 'when destroyed' do
    let(:imprint_1) { create(:imprint) }
    let(:imprint_2) { create(:imprint) }
    let(:populated_job) { create(:job, imprints: [imprint_1, imprint_2]) }
    let(:populated_order) { create(:order, jobs: [populated_job]) }

    it 'removes all jobs, imprints, trains', story_904: true do
      expect(populated_job).to be_persisted
      expect(imprint_1).to be_persisted
      expect(imprint_2).to be_persisted
      populated_order.destroy
      expect(populated_job).to_not be_persisted
      expect(imprint_1).to_not be_persisted
      expect(imprint_2).to_not be_persisted
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

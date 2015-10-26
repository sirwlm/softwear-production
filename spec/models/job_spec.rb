require 'spec_helper'

describe Job, job_spec: true do
  describe 'Relationships' do
    it { is_expected.to have_one :imprintable_train }
    it { is_expected.to have_many :imprints }
    it { is_expected.to belong_to :order }
  end

  describe 'Validations' do
    # it { is_expected.to validate_presence_of :imprintable_train }
  end

  describe '#imprint_state', story_876: true do
    let!(:job) { create(:job) }
    let(:complete_imprint_1) { create(:print, state: :complete, completed_at: 2.days.ago) }
    let(:complete_imprint_2) { create(:print, state: :complete, completed_at: 3.days.ago) }
    let(:incomplete_imprint_1) { create(:print, state: :pending_approval) }
    let(:incomplete_imprint_2) { create(:print, state: :pending_approval) }

    subject { job.imprint_state }

    context 'when the job contains an incomplete imprint' do
      before { job.imprints = [complete_imprint_1, incomplete_imprint_1] }
      it { is_expected.to eq 'Pending' }
    end

    context 'when the job contains only complete imprints' do
      before { job.imprints = [complete_imprint_1, complete_imprint_2] }
      it { is_expected.to eq 'Printed' }
    end
  end

  describe '#full_name' do 
    
    let(:job) { build(:job, order: build(:order), softwear_crm_id: 123) }

    context 'softwear_crm_id is not' do 
      it 'returns order name, job name, and the crm id' do 
        expect(job.full_name).to eq("#{job.order.name} - #{job.name} - CRMJob ##{job.softwear_crm_id}")
      end
    end

  end


  describe '#production_state', story_876: true do
    let!(:job) { create(:job) }
    let(:complete_imprintable_train) { create(:imprintable_train, state: :inventoried) }
    let(:incomplete_imprintable_train) { create(:imprintable_train, state: :ready_to_order) }
    let(:complete_preproduction_notes_train) { create(:preproduction_notes_train, state: :acknowledged) }
    let(:imprint_1) { create(:print, state: :pending_approval) }
    let(:imprint_2) { create(:print, state: :pending_approval) }

    subject { job.production_state }

    context 'when the job contains an incomplete train' do
      before do
        job.imprints = [imprint_1, imprint_2]
        job.imprintable_train = incomplete_imprintable_train
      end
      it { is_expected.to eq 'Pending' }
    end

    context 'when the job contains only complete trains' do
      before do
        imprint_1.update_attribute(:state, :complete)
        imprint_2.update_attribute(:state, :complete)
        job.imprints = [imprint_1, imprint_2]
        job.imprintable_train = complete_imprintable_train
        job.preproduction_notes_train = complete_preproduction_notes_train
      end
      it { is_expected.to eq 'Complete' }
    end
  end
end

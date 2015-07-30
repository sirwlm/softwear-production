require 'spec_helper'

describe ImprintGroup, story_768: true do
  describe '#full_name' do
    let!(:job_1) { build_stubbed(:job, name: 'first job') }
    let!(:job_2) { build_stubbed(:job, name: 'second job') }
    let!(:imprint_1) { build_stubbed(:print, name: 'imprint1', job: job_1) }
    let!(:imprint_2) { build_stubbed(:print, name: 'imprint2', job: job_2) }
    let!(:order) { build_stubbed(:order, name: 'The order', jobs: [job_1, job_2]) }
    let!(:imprint_group) { build_stubbed(:imprint_group, order: order, imprints: [imprint_1, imprint_2]) }

    subject { imprint_group.full_name }

    it { is_expected.to eq "The order: Group including 'first job imprint1', 'second job imprint2'" }
  end

  describe 'when destroyed' do
    let!(:job_1) { create(:job, name: 'first job') }
    let!(:job_2) { create(:job, name: 'second job') }
    let!(:imprint_1) { create(:print, name: 'imprint1', job: job_1) }
    let!(:imprint_2) { create(:print, name: 'imprint2', job: job_2) }
    let!(:imprint_group) { create(:imprint_group, imprints: [imprint_1, imprint_2]) }

    it 'nulls the imprint_group_ids of its imprints', busted: true do
      expect(imprint_1.imprint_group_id).to eq imprint_group.id
      expect(imprint_2.imprint_group_id).to eq imprint_group.id

      imprint_group.destroy

      expect(imprint_1.reload.imprint_group_id).to be_nil
      expect(imprint_2.reload.imprint_group_id).to be_nil
    end
  end

  describe 'when an imprint is added' do
    let!(:job) { create(:job, name: 'second job') }
    let!(:machine) { create(:machine) }
    let(:machine_2) { create(:machine) }
    let!(:imprint_1) { create(:print, name: 'imprint1', job: job, estimated_time: 2, machine_id: machine.id, require_manager_signoff: true) }
    let(:imprint_2) { create(:print, name: 'imprint2', job: job, estimated_time: 3, machine_id: machine_2.id, require_manager_signoff: false) }
    let!(:imprint_group) { create(:imprint_group, imprints: []) }

    context 'and there was previously no imprints' do
      it 'assigns machine, estimated time, and require manager signoff to that of the imprint' do
        expect(imprint_group.machine_id).to_not eq machine.id
        expect(imprint_group.estimated_time).to_not eq 2
        expect(imprint_group.require_manager_signoff).to_not eq true

        imprint_group.imprints << imprint_1

        expect(imprint_group.machine_id).to eq machine.id
        expect(imprint_group.estimated_time).to eq 2
        expect(imprint_group.require_manager_signoff).to eq true
      end
    end

    context 'and there were already imprints' do
      before do
        imprint_group.imprints << imprint_2
      end

      it 'does not alter machine, estimated time, or require manager signoff' do
        expect(imprint_group.machine_id).to_not eq machine.id
        expect(imprint_group.estimated_time).to_not eq 2
        expect(imprint_group.require_manager_signoff).to_not eq true

        imprint_group.imprints << imprint_1

        expect(imprint_group.machine_id).to_not eq machine.id
        expect(imprint_group.estimated_time).to_not eq 2
        expect(imprint_group.require_manager_signoff).to_not eq true
      end
    end
  end
end

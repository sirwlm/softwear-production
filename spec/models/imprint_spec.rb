require 'spec_helper'

describe Imprint, imprint_spec: true, story_110: true do
  let(:group) { create(:imprint_group) }

  describe 'searches', story_460: true do
    it { should have_searchable_field(:full_name) }
  end

  describe 'Machine Print Counts'

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
    it { is_expected.to belong_to(:job) }
    it { is_expected.to have_one(:order).through(:job) }
    it { is_expected.to belong_to(:screen_train) }
    it { is_expected.to have_many(:assigned_screens).through(:screen_train) }
    it { is_expected.to have_many(:screens).through(:assigned_screens) }
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

    context 'if imprint_group_id matches a group that contains a differently typed imprint', story_768: true do
      let!(:other_imprint) { create(:screen_print, imprint_group_id: group.id) }
      subject { create(:print) }

      it 'is not valid' do
        expect(subject).to be_valid
        subject.imprint_group_id = group.id
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'Before save' do
    context 'if completed_at is not set, but state is complete', fix_completion: true do
      let!(:print) { create(:print) }

      it 'sets completed_at to Time.now' do
        print.state = 'complete'
        expect(print.completed_at).to be_nil
        print.save!
        expect(print.completed_at).to_not be_nil
      end
    end

    context 'when type is changed' do
      let(:print) { create(:print) }

      it 'resets state to pending_approval', story_694: true do
        print.update_column :state, :ready_to_print
        print.type = 'ScreenPrint'
        print.save!
      
        expect(print.state.to_sym).to eq :pending_approval
      end
    end

    context 'when part of a group', story_768: true do
      let!(:time) { Date.today.to_datetime }
      let!(:group) { create(:imprint_group, completed_at: time, completed_by_id: user.id) }
      let!(:user) { create(:user) }
      let!(:print_in_group) { create(:print, imprint_group_id: group.id) }
      let!(:print) { create(:print) }

      it 'synchronizes state, completed_at, and completed_by_id with that of the group' do
        print_in_group.update_column :state, 'printed'
        group.imprints << print
        print.reload
        expect(print.completed_at).to eq time
        expect(print.completed_by_id).to eq user.id
        expect(print.state).to eq 'printed'
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
        expect(subject.display).to eq "(UNAPPROVED) #{subject.full_name}"
      end
    end

    context 'when not completed' do
      before { allow(subject).to receive(:completed?).and_return false }

      it 'equals name' do
        expect(subject.display).to eq "(UNAPPROVED) #{subject.full_name}"
      end
    end
  end

  describe '#order_name' do

    context 'order exists' do
      let(:order) { create(:order, jobs: [create(:job)]) }
      let(:imprint) { order.imprints.first }

      it 'returns the order name' do
        expect(imprint.order_name).to eq(order.name)
      end

    end

    context 'job nil' do

      let(:imprint) { create(:imprint, job: nil) }

      it 'returns n/a' do
        expect(imprint.order_name).to eq('n/a')
      end
    end

  end

  describe '#job_name' do

    context 'job exists' do
      let(:job) { create(:job) }
      let(:imprint) { job.imprints.first }

      it 'returns the job name' do
        expect(imprint.job_name).to eq(job.name)
      end

    end

    context 'job nil' do

      let(:imprint) { create(:imprint) }

      it 'returns n/a' do
        expect(imprint.job_name).to eq('n/a')
      end
    end

  end

  describe '#order_deadline_day' do
    context 'deadline is set' do
      let(:order) { create(:order, jobs: [create(:job)], deadline: '2015-06-29') } # 6/29 is a monday
      let(:imprint) { order.imprints.first }

      it 'returns the name of the weekday and the day/month' do
        expect(imprint.order_deadline_day).to eq("Mon 06/29")
      end

    end

    context 'deadline is not set' do
      let(:order) { create(:order, jobs: [create(:job)], deadline: nil) }
      let(:imprint) { order.imprints.first }

      it 'returns no deadline' do
        expect(imprint.order_deadline_day).to eq('No Deadline')
      end
    end

  end


  describe '#full_name' do
    let(:order) { create(:order, jobs: [create(:job)], deadline: '2015-06-29') }
    let(:imprint) { order.imprints.first }

    it 'returns the contatenated deadline weekday, order, job, and imprint name and quantity' do
      expect(imprint.full_name).to eq("#{imprint.order_deadline_day} - #{imprint.order_name} - #{imprint.job.name} - #{imprint.name} (#{imprint.count})")
    end

  end
end

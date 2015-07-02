require 'spec_helper'

describe Imprint, imprint_spec: true, story_110: true do
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
      expect(imprint.full_name).to eq("#{imprint.order_deadline_day} - #{imprint.order_name} -#{imprint.job.name} - #{imprint.name} (#{imprint.count})")
    end

  end

end

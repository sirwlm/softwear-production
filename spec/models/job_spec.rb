require 'spec_helper'

describe Job, job_spec: true do

  describe 'Relationships' do
    it { is_expected.to.have_one :imprintable_train }
  end

  describe 'Validations' do
    it { is_expected.to.validate_presence_of :imprintable_train }
  end

  describe 'Callbacks' do
    it 'assigns the imprintable train', story_104: true do
      job = Job.new
      expect(job.imprintable_train).to receive(:create)
      job.assign_train
    end
  end

end

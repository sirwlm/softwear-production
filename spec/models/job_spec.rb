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

  describe 'Callbacks' do
    it 'assigns the imprintable train', story_104: true do
      job = Job.new
      expect_any_instance_of(ImprintableTrain).to receive(:save)
      job.save
    end
  end

end

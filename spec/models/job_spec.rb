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
    
    let(:job) { create(:job) }

    it 'creates an imprintable train', story_104: true do
      expect(job.imprintable_train).to_not be_nil
    end
  end

end

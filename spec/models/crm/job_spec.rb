require 'spec_helper'

describe Crm::Job, job_spec: true, story_200: true do
  it { is_expected.to be_a RemoteModel }
end
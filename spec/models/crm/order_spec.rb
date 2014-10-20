require 'spec_helper'

describe Crm::Order, order_spec: true, story_200: true do
  it { is_expected.to be_a RemoteModel }
end
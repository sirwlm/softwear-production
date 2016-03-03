require 'spec_helper'

describe UserRole do
  it { is_expected.to belong_to :role }
end

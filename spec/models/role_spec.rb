require 'spec_helper'

describe Role do
  it { is_expected.to have_many :user_roles }
  it { is_expected.to have_many :users }
end

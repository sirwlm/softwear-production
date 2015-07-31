require 'spec_helper'

describe User, story_115: true do
  describe 'validations'
  it { is_expected.to validate_uniqueness_of :email }
  it { is_expected.to allow_value('test@umich.edu').for :email }
  it { is_expected.to_not allow_value('lolololol').for :email }
  it { is_expected.to have_many :user_roles }
  it { is_expected.to have_many :roles }

  describe '#full_name' do
    let!(:user) { build_stubbed(:blank_user, first_name: 'First', last_name: 'Last') }

    subject do
      build_stubbed(
          :blank_user,
          first_name: 'First', last_name: 'Last'
      )
          .full_name
    end

    it { is_expected.to eq 'First Last' }
  end
end

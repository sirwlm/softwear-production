require 'spec_helper'
require 'cancan/matchers'

describe ApiSetting, api_spec: true, story_201: true do
  describe 'Relationships' do
    it { is_expected.to have_db_column :endpoint }
    it { is_expected.to have_db_column :slug }
    it { is_expected.to have_db_column :auth_token }
    it { is_expected.to have_db_column :auth_email }
    it { is_expected.to have_db_column :homepage }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :endpoint }
    it { is_expected.to validate_presence_of :auth_token }
    it { is_expected.to validate_inclusion_of(:slug).in_array(%w(crm)) }
    it { is_expected.to validate_uniqueness_of :slug }
    it { is_expected.to allow_value('http://foo.com/api').for(:endpoint) }
    it { is_expected.to allow_value('http://foo.com/api').for(:homepage) }
    it { is_expected.to_not allow_value('not a url').for(:endpoint) }
    it { is_expected.to_not allow_value('not a url').for(:homepage) }
  end

  describe 'User' do
    describe "abilities" do
      subject(:ability) { Ability.new(user) }
      let(:user) { nil }

      context "when is an admin" do
        let(:user) { create(:admin) }

        it { should be_able_to(:manage, ApiSetting.new) }
      end

      context "when is a user" do
        let(:user) { create(:user) }

        it { should_not be_able_to(:manage, ApiSetting.new) }
      end
    end
  end
end

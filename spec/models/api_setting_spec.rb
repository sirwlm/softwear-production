require 'spec_helper'

describe ApiSetting, api_spec: true, story_201: true do
  it { is_expected.to have_db_column :endpoint }
  it { is_expected.to have_db_column :site_name }
  it { is_expected.to have_db_column :auth_token }
  it { is_expected.to have_db_column :homepage }

  it { is_expected.to validate_presence_of :endpoint }
  it { is_expected.to validate_presence_of :auth_token }
  it { is_expected.to validate_inclusion_of(:site_name).in_array(%w(crm)) }
  it { is_expected.to validate_uniqueness_of :site_name }
end

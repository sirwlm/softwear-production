require 'spec_helper'
include Devise::TestHelpers

shared_context 'signed_in_as_user', :signed_in_as_user do
  let!(:user) { create(:user) }

  before(:each) { sign_in user }
end


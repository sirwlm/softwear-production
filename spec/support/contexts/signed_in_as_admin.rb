require 'spec_helper'
include Devise::TestHelpers

shared_context 'signed_in_as_admin', :signed_in_as_admin do
  let!(:admin) { create(:admin) }

  before(:each) { sign_in admin }
end

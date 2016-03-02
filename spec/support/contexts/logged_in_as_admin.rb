require 'spec_helper'
include Warden::Test::Helpers

shared_context 'logged_in_as_admin', :logged_in_as_admin do
  let!(:admin) { create(:admin) }

  before(:each) { sign_in_as admin }
end

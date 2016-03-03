require 'spec_helper'
include Warden::Test::Helpers

shared_context 'logged_in_as_user', :logged_in_as_user do
  let!(:user) { create(:user) }

  before(:each) { login_as user }
end

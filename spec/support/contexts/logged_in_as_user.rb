require 'spec_helper'

shared_context 'logged_in_as_user', :logged_in_as_user do
  let!(:user) { create(:user) }

  before(:each) { sign_in_as user }
end

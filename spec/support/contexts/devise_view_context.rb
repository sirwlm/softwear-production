require 'spec_helper'
include Devise::TestHelpers

shared_context 'devise_view_setup', :devise_view_setup do
  before(:each) do
    allow(view).to receive(:resource).and_return(User.new)
    allow(view).to receive(:resource_name).and_return(:user)
    allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
  end
end

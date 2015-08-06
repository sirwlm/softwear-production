require 'spec_helper'

describe ApiSettingsController, api_spec: true, story_201: true do
  include_context 'signed_in_as_admin'

  describe 'GET #new' do
    it 'renders edit' do
      expect(get :new).to render_template(:edit)
    end
    
    it 'assigns @api_setting to a new record' do
      get :new
      expect(assigns(:api_setting)).to be_a_new ApiSetting
    end
  end
end

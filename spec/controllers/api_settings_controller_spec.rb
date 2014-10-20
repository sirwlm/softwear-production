require 'spec_helper'

describe ApiSettingsController, api_spec: true, story_201: true do
  describe 'GET #new' do
    subject { get :new }

    it { is_expected.to render_template(:edit) }
    it 'assigns @api_setting to a new record' do
      expect(assigns(:api_setting)).to be_a new_record
    end
  end
end
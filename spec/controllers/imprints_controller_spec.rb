require 'spec_helper'

describe ImprintsController, imprint_spec: true, story_113: true do
  include_context 'signed_in_as_user'
  let!(:imprint) { create(:imprint) }

  describe 'GET #show' do
    it 'renders show.js.erb' do
      get :show, id: imprint.id, format: 'js'
      expect(response).to render_template('show')
    end
  end
end

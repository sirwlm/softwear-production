require 'spec_helper'

describe ImprintsController, imprint_spec: true, story_113: true do
  let!(:imprint) { create(:imprint) }

  describe 'GET #show' do
    it 'renders show.js.erb' do
      get :show, id: imprint.id, format: 'js'
      expect(response).to render_template('show')
    end
  end
end

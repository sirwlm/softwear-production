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

  describe 'PUT #update' do
    context 'when machine_id and scheduled_at are set to nil' do
      it 'renders imprint unscheduled_entry' do
        put :update, id: imprint.id, imprint: { scheduled_at: nil, machine_id: nil }, format: 'json'
        expect(response).to render_template 'imprints/_unscheduled_entry'
      end
    end
  end
end

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

  describe 'PATCH #complete', story_465: true do
    context 'passed an imprint id through its route' do
      let!(:user) { create :user }

      it 'marks completed_at to Time.now, and completed_by_id to the current_user' do
        now = Time.now
        allow(Time).to receive(:now).and_return now
        allow(controller).to receive(:current_user).and_return user

        patch :complete, id: imprint.id
        expect(imprint.reload.completed_at).to eq now.to_s(:db)
        expect(imprint.reload.completed_by).to eq user
      end
    end
  end
end

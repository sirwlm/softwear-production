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

  describe 'PUT #complete', story_465: true do
    let(:user) { create(:user) }

    context 'given an imprint id, and a user id' do
      it 'marks completed_at to Time.now, and completed_by_id to the given user id' do
        now = Time.now
        allow(Time).to receive(:now).and_return now

        put :complete, id: imprint.id, user_id: user.id
        expect(imprint.reload.completed_at).to eq now
        expect(imprint.reload.completed_by).to eq user
      end
    end
  end
end

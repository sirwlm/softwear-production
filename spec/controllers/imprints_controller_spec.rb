require 'spec_helper'

describe ImprintsController, imprint_spec: true, story_113: true do
  include_context 'signed_in_as_user'
  let!(:imprint) { create(:print) }

  describe 'GET #show' do
    it 'renders show.js.erb' do
      xhr :get, :show, id: imprint.id, format: 'js'
      expect(response).to render_template('show')
    end
  end

  describe 'PUT #update' do
    context 'when machine_id and scheduled_at are set to nil' do
      it 'renders imprint for_calendar' do
        put :update, id: imprint.id, imprint: { scheduled_at: nil, machine_id: nil }, format: 'json'
        expect(response).to render_template 'machines/_calendar_entry'
      end
    end
  end

  describe 'PATCH #transition', story_545: true do
    let(:user) { create :user }

    before do
      allow_any_instance_of(Print).to receive(:fire_state_event).with('printing_complete')
    end

    context 'when params[:transition] = :printing_complete' do
      it 'marks completed_at to Time.now, and completed_by_id to the given user' do
        now = Time.now
        allow(Time).to receive(:now).and_return now

        patch :transition, id: imprint.id, user_id: user.id, transition: :printing_complete, format: :js
        expect(imprint.reload.completed_at).to eq now.to_s(:db)
        expect(imprint.reload.completed_by).to eq user
      end
    end

    context 'without a user_id' do
      it "doesn't mark completed_at or completed_by_id" do
        patch :transition, id: imprint.id, transition: :printing_complete, format: :js
        expect(imprint.reload.completed_at).to be_nil
        expect(imprint.reload.completed_by).to be_nil
      end
    end
  end
end

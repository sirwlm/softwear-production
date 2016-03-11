require 'spec_helper'

describe MetricsController, type: :controller do
  include_context 'signed_in_as_user'

  context 'as a logged in user' do
    context 'with a ScreenPrint' do
      let!(:screen_print) { create(:screen_print, completed_at: Time.now) }

      describe 'POST #create' do
        it 'finds the object and calls create_metrics on it' do
          expect_any_instance_of(ScreenPrint).to receive(:create_metrics)
          post :create, object_class: screen_print.class.name, object_id: screen_print.id, format: :js
          expect(assigns(:object)).to be_an_instance_of(screen_print.class)
        end
      end
    end
  end
end

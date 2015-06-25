require 'spec_helper'

describe ScreensController do 
  include_context 'signed_in_as_user' 

  let(:screen) { create(:screen) }

  describe 'GET #transition' do 
    context 'called with params:id :transition]' do
      it 'does all the stuff Im listing below' do
        
        # post :transition, {make: these, valid: parameters}, format: :js
        # expect @screen to get assigned with a screen
        # expect any instance of a screen to receive fire_state_event with the parameter :transition
        # expect any instance of a screen to receive create_activity with the proper parameters 
        # expect controller to set flash[:notice] 
      end
    end

    context 'called with params :id, :transition = meshed, :mesh_type' do 
        # it does the above, but ALSO updates an attribute. so check that update attribute gets called with the proper parameters. 
      #
    end

    # what params come in when you click broke
    # what params come when you click bad prep 
  end

  describe 'POST #transition js' do

    context 'called with params :id, :transition, :expected_state, :fast_scan' do 
      
      context 'Screen does not exist' do 
        it 'assigns nothing' do 
          post :transition, id: screen.id + 1, transition: 'arbitrary', expected_state: 'arbitrary', format: 'js'
          expect(assigns(:screen)).to be_nil
          expect(flash[:alert]).to eq('Invalid Screen ID')
          expect(response).to render_template('transition')
        end
      end

      context 'screen exists but is not in expected state' do 
        it 'assigns nothing' do
          post :transition, id: screen.id, transition: 'arbitrary', expected_state: 'new', format: 'js'
          expect(assigns(:screen)).not_to be_nil 
          expect(flash[:alert]).to eq('Screen was not in the expected state')
          expect(response).to render_template('transition')
        end
      end

      context 'screen exists and transitions successfully' do 
        it 'flashes a success message, creates activity, fires event, calls load_screens_grouped_by_type' do
          expect_any_instance_of(Screen).to receive(:fire_state_event).with('removed_from_production')
          expect_any_instance_of(Screen).to receive(:create_activity)
          expect(controller).to receive(:load_screens_grouped_by_type)

          post :transition, id: screen.id, transition: 'removed_from_production', expected_state: 'in_production', format: 'js'
          expect(assigns(:screen)).not_to be_nil 
          expect(flash[:notice]).to eq('Screen state was successfully updated')
          expect(response).to render_template('transition')
        end
      end
    
    end

  end

end


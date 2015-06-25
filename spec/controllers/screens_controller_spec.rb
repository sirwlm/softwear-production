require 'spec_helper'

describe ScreensController do 
  include_context 'signed_in_as_user' 

  let(:screen) { create(:screen) }

  describe 'GET #transition' do 
    context 'called with params:id :transition where transition isnt a fail' do
      it 'transitions, creates activity, sets the flash, and renders' do
        expect_any_instance_of(Screen).to receive(:fire_state_event).with('removed_from_production')
        expect_any_instance_of(Screen).to receive(:create_activity)
        expect(controller).to receive(:transition_parameters)
        expect(controller).to receive(:load_screens_grouped_by_type)
        xhr :get, :transition, id: screen.id, transition: 'removed_from_production', format: 'js' 
        expect(assigns(:screen)).to eq(screen)

        expect(flash[:notice]).to eq('Screen state was successfully updated')
        expect(response).to render_template('transition')
      end
    end

    context 'called with params :id, :transition = meshed, :mesh_type' do 
      let(:screen) { create(:screen, state: 'broken') }

      it 'updates screens mesh value, transitions, creates activity, sets the flash, and renders' do
        expect_any_instance_of(Screen).to receive(:fire_state_event).with('meshed')
        expect_any_instance_of(Screen).to receive(:create_activity)
        expect_any_instance_of(Screen).to receive(:update_attribute).with(:mesh_type, '110')
        expect(controller).to receive(:transition_parameters)
        expect(controller).to receive(:load_screens_grouped_by_type)
        xhr :get, :transition, id: screen.id, transition: 'meshed',  mesh_type: '110', format: 'js' 
        expect(assigns(:screen)).to eq(screen)

        expect(flash[:notice]).to eq('Screen state was successfully updated')
        expect(response).to render_template('transition')
      end
    end

    context 'called with params :id, :transition = broke or bad prep, :reason' do 
      it 'transitions, creates activity, sets the flash, and renders' do
        expect_any_instance_of(Screen).to receive(:fire_state_event).with('meshed')
        expect_any_instance_of(Screen).to receive(:create_activity)
        expect(controller).to receive(:transition_parameters)
        expect(controller).to receive(:load_screens_grouped_by_type)
        xhr :get, :transition, id: screen.id, transition: 'meshed',  reason: 'anything', format: 'js' 
        expect(assigns(:screen)).to eq(screen)

        expect(flash[:notice]).to eq('Screen state was successfully updated')
        expect(response).to render_template('transition')
      end
    end
 
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
          expect(controller).to receive(:transition_parameters)
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


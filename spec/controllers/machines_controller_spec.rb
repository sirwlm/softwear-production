require 'spec_helper'

describe MachinesController, machine_spec: true, story_113: true do
  include_context 'signed_in_as_admin'

  let!(:machine) { create(:machine) }
  let!(:scheduled_imprint) { create(:print, scheduled_at: Time.now, estimated_time: 1, machine: machine ) }

  describe 'POST #create' do
    context 'with valid input' do
      it 'redirects to #show' do
        post :create, machine: attributes_for(:machine)
        expect(response).to redirect_to(machines_path)
      end

    end

    context 'with invalid input' do
      it 'renders #new' do
        post :create, machine: attributes_for(:blank_machine, name: nil)
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid input' do
      it 'redirects to #show' do
        put :update, id: machine.id, machine: attributes_for(:machine, name: 'New Name')
        expect(response).to redirect_to(machines_path)
      end
    end

    context 'with invalid input' do
      it 'renders #edit' do
        put :update, id: machine.id, machine: attributes_for(:machine, name: nil)
        expect(response).to render_template('edit')
      end
    end

  end

  describe 'GET #scheduled' do
    it 'assigns @machine', scheduled: true do
      get :scheduled, { machine_id: machine.id, format: :json }
      expect(assigns[:machine]).to eq machine
    end
  end

end


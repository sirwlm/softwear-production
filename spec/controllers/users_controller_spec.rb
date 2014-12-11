require 'spec_helper'

describe UsersController, user_spec: true, story_116: true do
  include_context 'signed_in_as_admin'
  let!(:user) { create(:user) }

  describe 'POST #create' do
    context 'with valid input' do
      it 'redirects to #index' do
        post :create, user: attributes_for(:user)
        expect(response).to redirect_to(users_path)
      end
    end

    context 'with invalid input' do
      it 'renders #new' do
        post :create, user: attributes_for(:blank_user, email: nil)
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid input' do
      it 'redirects to #index' do
        put :update, id: user.id, user: attributes_for(:user, last_name: 'Dinkleberg')
        expect(response).to redirect_to(users_path)
      end
    end

    context 'with invalid input' do
      it 'renders #edit' do
        put :update, id: user.id, user: attributes_for(:user, email: nil)
        expect(response).to render_template('edit')
      end
    end

  end

  describe 'GET #index' do
    it 'assigns @users' do
      get :index
      expect(assigns[:users]).to eq [user]
    end
  end
end


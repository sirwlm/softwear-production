SoftwearProduction::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'dashboard#index'
  get 'dashboard/index'
  get 'dashboard/calendar'

  resources :machines do
    get :scheduled
  end

  resources :imprints do

  end

  resources :api_settings
  resources :users, only: [:index, :new, :edit, :update, :destroy, :patch]
  post '/users/create_user', to: 'users#create', controller: 'users', as: :create_user
  delete '/users/delete_user/:id', to: 'users#destroy', controller: 'users', as: :destroy_user
end

SoftwearProduction::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'dashboard#index'
  get 'dashboard/index'
  get 'dashboard/calendar'
  post 'dashboard/filter'

  resources :machines do
    get :scheduled
  end

  resources :imprints do
    member do
      patch 'complete', to: 'imprints#complete'
      patch 'approve', to: 'imprints#approve'
    end
  end

  resources :api_settings
  resources :jobs
  resources :users, only: [:index, :new, :edit, :update, :destroy, :patch]
  post '/users/create_user', to: 'users#create', controller: 'users', as: :create_user
  delete '/users/delete_user/:id', to: 'users#destroy', controller: 'users', as: :destroy_user
end

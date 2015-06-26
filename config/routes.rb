SoftwearProduction::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'dashboard#index'
  get 'dashboard/index'
  get 'dashboard/calendar'
  post 'dashboard/filter'

  resources :machines do
    get :scheduled
    collection do
      get :calendar_events
    end
  end

  resources :orders do
    resources :jobs do
      resources :imprints
    end
  end

  resources :imprints do
    member do
      patch ':transition', to: 'imprints#transition', as: :transition
    end
  end

  resources :maintenances

  resources :api_settings
  resources :jobs

  resources :screens do
    collection do
      get :lookup, action: :lookup
      get :status, action: :status
      get :fast_scan, action: :fast_scan
    end
  end

  get '/screens/:id/:transition' =>  'screens#transition', as: :transition_screen
  post '/screens/fast_scan' => 'screens#transition', as: :fast_scan_transition_screen

  resources :users, only: [:index, :new, :edit, :update, :destroy, :patch]
  post '/users/create_user', to: 'users#create', controller: 'users', as: :create_user
  delete '/users/delete_user/:id', to: 'users#destroy', controller: 'users', as: :destroy_user
end

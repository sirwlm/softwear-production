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
    resources :imprint_groups, shallow: true do
      member do
        patch ':transition', to: 'imprint_groups#transition', as: :transition
      end
    end
  end

  resources :imprints, except: [:new, :create] do
    member do
      patch ':transition', to: 'imprints#transition', as: :transition
    end
  end

  resources :maintenances do
    member do
      post :complete
    end
  end

  resources :fba_bagging_trains, only: [:show, :update, :destroy]

  resources :api_settings
  resources :jobs

  resources :screens do
    collection do
      get :lookup, action: :lookup
      get :status, action: :status
      get :fast_scan, action: :fast_scan
    end
  end

  get '/reports/:report_type/(:start_date...:end_date)' => 'reports#show', as: :report

  get '/screens/:id/:transition' =>  'screens#transition', as: :transition_screen
  post '/screens/fast_scan' => 'screens#transition', as: :fast_scan_transition_screen

  resources :users, only: [:index, :new, :edit, :update, :destroy, :patch]
  post '/users/create_user', to: 'users#create', controller: 'users', as: :create_user
  delete '/users/delete_user/:id', to: 'users#destroy', controller: 'users', as: :destroy_user

  get '/imprintables/dashboard', to: 'imprintables#index', as: :imprintable_dashboard

  resources :trains, only: :create
  patch '/:model_name/:id/transition_to/:event', to: 'trains#transition', as: :transition_train
  get '/:model_name/:id/new_train/:train_type', to: 'trains#new', as: :new_train
  get '/:model_name/:id/train', to: 'trains#show', as: :show_train
end

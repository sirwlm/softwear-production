require 'sidekiq/web'

SoftwearProduction::Application.routes.draw do
  mount ActsAsWarnable::Engine => '/'
  mount Softwear::Engine => '/'

  root 'dashboard#index'
  get 'dashboard/index'
  get 'dashboard/calendar'
  post 'dashboard/filter'
  post 'dashboard/view'

  get '/set-session-token', to: 'users#set_session_token', as: :set_session_token
  get '/clear-user-query-cache', to: 'users#clear_query_cache', as: :clear_user_query_cache
  get '/sign_out', to: 'users#sign_out', as: :sign_out

  resources :machines do
    get :scheduled
    get :agenda
    collection do
      get :calendar_events
    end
  end

  resources :orders do
    member do
      get :force_complete, to: 'orders#force_complete', as: :force_complete
      get :dashboard, to: 'orders#dashboard', as: :dashboard_for
      get :imprint_groups, to: 'orders#imprint_groups', as: :imprint_groups
    end

    resources :jobs do
      resources :imprints
    end
    resources :imprint_groups, shallow: true do
      member do
        patch ':transition', to: 'imprint_groups#transition', as: :transition
      end
    end
  end

  resources :imprints, only: [:update] do
    member do
      patch ':transition', to: 'imprints#transition', as: :transition
      get :proof_info
    end
  end

  get 'imprint_or_group/:id/:imprint_or_group/confirm_imprint_data', to: 'imprints#confirm_imprint_data', as: :imprint_or_group_data
  post 'imprint_or_group/:id/:imprint_or_group/confirm_imprint_data', to: 'imprints#confirm_imprint_data', as: :confirm_imprint_or_group_data

  resources :maintenances do
    member do
      post :complete
    end
  end

  resources :fba_bagging_trains, only: [:show, :update, :destroy]
  resources :stage_for_fba_bagging_trains, only: [:show, :update, :destroy]
  resources :custom_ink_color_trains, only: [:show, :update, :destroy]
  resources :preproduction_notes_trains, only: [:show, :update]
  resources :shipment_trains, only: [:show, :update]
  resources :digitization_trains, only: [:show, :update, :destroy]
  resources :ar3_trains, only: [:show, :update, :destroy]
  resources :imprintable_trains, only: [:update]

  resources :api_settings
  resources :jobs
  resources :screen_trains
  post 'metrics/:object_class/:object_id' => 'metrics#create', as: 'metrics'
  resources :metric_types do
    collection do
      get 'activities_for/:class_name' => 'metric_types#metric_activities_for', as: :metric_activities_for
    end
  end
  resources :public_activities, only: [:update]
  get 'pre_production_art_dashboard' => 'pre_production#art_dashboard'
  get 'pre_production_dashboard' => 'dashboard#pre_production'
  get 'post_production_dashboard' => 'dashboard#post_production'

  resources :screens do
    collection do
      get :lookup, action: :lookup
      get :status, action: :status
      get :fast_scan, action: :fast_scan
      get :fix_state, action: :fix_state
      post :fix_state, action: :force_transition
    end
  end

  get '/screens/:id/:transition' =>  'screens#transition', as: :transition_screen
  post '/screens/fast_scan' => 'screens#transition', as: :fast_scan_transition_screen

  resources :users, only: [:index, :new, :edit, :update, :destroy, :patch]
  post '/users/create_user', to: 'users#create', controller: 'users', as: :create_user
  delete '/users/delete_user/:id', to: 'users#destroy', controller: 'users', as: :destroy_user

  get '/imprintables/dashboard', to: 'imprintables#index', as: :imprintable_dashboard

  resources :trains, only: :create
  get '/trains/dangling', to: 'trains#dangling', as: :dangling_trains
  delete '/trains/dangling', to: 'trains#destroy_dangling'
  patch '/:model_name/:id/transition_to/:event', to: 'trains#transition', as: :transition_train
  patch '/:model_name/:id/undo', to: 'trains#undo', as: :train_undo
  get '/:model_name/:id/new_train/:train_type', to: 'trains#new', as: :new_train
  get '/:model_name/:id/train', to: 'trains#show', as: :show_train
  delete '/:model_name/:id/train', to: 'trains#destroy', as: :train

  namespace :api do
    resources :orders, :jobs, :imprints, :imprintable_trains, :imprint_groups

    get '/constants',        to: 'constants#index'
    get '/constants/*const', to: 'constants#show',  as: :constant

    get    '/trains/:train_class',            to: 'trains#index'
    get    '/trains/:train_class/:id',        to: 'trains#show'
    post   '/trains/:train_class',            to: 'trains#create'
    put    '/trains/:train_class/:id',        to: 'trains#update'
    delete '/trains/:train_class/:id',        to: 'trains#destroy'
    patch  '/trains/:train_class/:id/:event', to: 'trains#transition'
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
end

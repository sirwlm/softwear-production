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

end

SoftwearProduction::Application.routes.draw do

  root 'dashboard#index'
  get "dashboard/index"
  get "dashboard/calendar"

  resources :machines do
    get :scheduled
  end

  resources :imprints do

  end

end
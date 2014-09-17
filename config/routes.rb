SoftwearProduction::Application.routes.draw do

  root 'dashboard#index'
  get "dashboard/index"
  get "dashboard/calendar"
end
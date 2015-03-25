class DashboardController < ApplicationController
  before_filter :assign_fluid_container, only: [:calendar]

  def index
  end

  def calendar

  end

  def filter
    session[:show_machines] ||= {}

    case params[:type]
    when 'hide' then session[:show_machines].delete(params[:id])
    when 'show'
      machine = Machine.find(params[:id])
      session[:show_machines][params[:id]] = machine.name
    end

    render json: { ok: true };
  end

end

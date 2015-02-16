class DashboardController < ApplicationController
  before_filter :assign_fluid_container, only: [:calendar]

  def index
  end

  def calendar

  end

end

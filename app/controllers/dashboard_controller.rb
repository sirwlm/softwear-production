class DashboardController < ApplicationController
  before_filter :assign_fluid_container, only: [:calendar, :post_production]
  before_filter :initialize_post_prod_train_classes, only: [:post_production]

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

  def post_production
    assign_fluid_container
    q = params[:q]
    @trains = Sunspot.search @post_production_train_classes do
      if q
        fulltext q[:text] unless q[:text].blank?  
        with :class_name, q[:class_name] unless q[:class_name].blank?
        with :order_state, q[:order_state] unless q[:order_state].blank?
        with :order_imprint_state, q[:order_imprint_state] unless q[:order_imprint_state].blank?
        order_by :created_at, :desc
      else
        with :complete, false
      end

      paginate page: params[:page] || 1
    end
      .results
  end

  private

  def initialize_post_prod_train_classes 
    @post_production_train_classes = Train.train_types[:post_production].map{|x| x.to_s.constantize }
  end

end

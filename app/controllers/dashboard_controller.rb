class DashboardController < ApplicationController
  before_filter :assign_fluid_container, only: [:calendar, :post_production, :pre_production]

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
  
  def pre_production
    initialize_train_classes(:pre_production) 
    q = params[:q]
    @trains = Sunspot.search @train_classes do
      if q
        fulltext q[:text] unless q[:text].blank?  
        with :class_name, q[:class_name] unless q[:class_name].blank?
        with(:due_at).greater_than(q[:due_at_after]) unless q[:due_at_after].blank?
        with(:due_at).less_than(q[:due_at_before]) unless q[:due_at_before].blank?
        with(:complete, q[:complete] == 'true') unless q[:complete].blank?
        with(:order_complete, q[:order_complete] == 'true') unless q[:order_complete].blank?
        with(:order_deadline).greater_than(q[:order_deadline_after]) unless q[:order_deadline_after].blank?
        with(:order_deadline).less_than(q[:order_deadline_before]) unless q[:order_deadline_before].blank?
      else
        with :complete, false
      end

      order_by :due_at, :asc
      paginate page: params[:page] || 1
    end
      .results
  end

  def post_production
    initialize_train_classes(:post_production)
    assign_fluid_container
    q = params[:q]
    @trains = Sunspot.search @train_classes do
      if q
        fulltext q[:text]                                            unless q[:text].blank?  
        with :class_name, q[:class_name]                             unless q[:class_name].blank?
        with(:due_at).greater_than(q[:due_at_after])                 unless q[:due_at_after].blank?
        with(:due_at).less_than(q[:due_at_before])                   unless q[:due_at_before].blank?
        with(:complete, q[:complete] == 'true')                      unless q[:complete].blank?
        with(:order_complete, q[:order_complete] == 'true')          unless q[:order_complete].blank?
        with(:order_deadline).greater_than(q[:order_deadline_after]) unless q[:order_deadline_after].blank?
        with(:order_deadline).less_than(q[:order_deadline_before])   unless q[:order_deadline_before].blank?
        with(:fba, q[:fba] == 'true')                                unless q[:fba].blank?
      else
        with :complete, false
      end

      order_by :due_at, :asc
      paginate page: params[:page] || 1
    end
      .results
  end

  private

  def initialize_train_classes(train_types)
    @train_classes = Train.train_types[train_types.to_sym].map{|x| x.to_s.constantize }
    @train_class_name_options = @train_classes.map(&:to_s)
  end

end

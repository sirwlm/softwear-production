class DashboardController < ApplicationController
  before_filter :assign_fluid_container, only: [:calendar, :post_production, :pre_production]

  def index
  end

  def view
    if params[:view] =~ /Mobile/
      session[:current_view] = "Mobile"
    else
      session[:current_view] = "Desktop"
    end

    redirect_to params[:return_to] || root_path
  end

  def calendar
    if Rails.env.development? || Rails.env.test?
      @calender_refresh_rate = 7500 
    else
      @calender_refresh_rate = 300000  
    end
  end

  def filter
    query = {
      user_id:    current_user.id,
      machine_id: params[:id]
    }

    ok = true

    case params[:type]
    when 'hide' then ShownMachine.where(query).destroy_all
    when 'show' then ShownMachine.find_or_create_by(query)
    else ok = false
    end

    render json: { ok: ok };
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
        with(:train_scheduled_at).equal_to(q[:train_scheduled_at]) unless q[:train_scheduled_at].blank?
        without :state, 'canceled'
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
        without :state, 'canceled'
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

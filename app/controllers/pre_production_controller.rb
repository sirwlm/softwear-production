class PreProductionController < ApplicationController
  def art_dashboard
    assign_fluid_container
    q = params[:q]
    @trains = Sunspot.search ScreenTrain, Ar3Train, DigitizationTrain do
      if q
        fulltext q[:text] unless q[:text].blank?  
        with :assigned_to_id, q[:assigned_to_id] unless q[:assigned_to_id].blank?
        with(:due_at).greater_than(q[:due_at_after]) unless q[:due_at_after].blank?
        with(:due_at).less_than(q[:due_at_before])     unless q[:due_at_before].blank?
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
end

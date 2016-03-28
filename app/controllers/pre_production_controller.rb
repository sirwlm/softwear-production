class PreProductionController < ApplicationController
  before_action :build_options_for_state, only: :art_dashboard
  
  def art_dashboard
    assign_fluid_container
    q = params[:q]

    @trains = Sunspot.search ScreenTrain, Ar3Train, DigitizationTrain do
      if q
        fulltext q[:text] unless q[:text].blank?  
        with :assigned_to_id, q[:assigned_to_id] unless q[:assigned_to_id].blank?
        with(:due_at).greater_than(q[:due_at_after]) unless q[:due_at_after].blank?
        with(:due_at).less_than(q[:due_at_before])     unless q[:due_at_before].blank?
        with :class_name, q[:class_name] unless q[:class_name].blank?
        with :state, q[:state] unless q[:state].blank?
        with(:order_complete, q[:order_complete] == 'true') unless q[:order_complete].blank?
      else
        with :complete, false
      end
      order_by :due_at, :asc
      paginate page: params[:page] || 1
    end
      .results
  end

  private

  def build_options_for_state
    @train_states = ScreenTrain.train_machine.states.map{|s| [s.name.to_s.humanize, s.name]} + 
      Ar3Train.train_machine.states.map{|s| [s.name.to_s.humanize, s.name]} + 
      DigitizationTrain.train_machine.states.map{|s| [s.name.to_s.humanize, s.name]}
  end
end

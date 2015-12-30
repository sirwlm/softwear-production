class ImprintablesController < ApplicationController

  def index
    q = params[:q]
    @imprintable_trains = ImprintableTrain.search do
      if q
        fulltext q[:text] unless q[:text].blank?
        with :expected_arrival_date, q[:expected_arrival_date].to_date unless q[:expected_arrival_date].blank?
        with :state, q[:state] unless q[:state].blank?
        with :order_production_state, q[:order_state] unless q[:order_state].blank?
        with :order_imprint_state, q[:order_imprint_state] unless q[:order_imprint_state].blank?
        with :job_production_state, q[:job_state] unless q[:job_state].blank?
        with :job_imprint_state, q[:job_imprint_state] unless q[:job_imprint_state].blank?

        order_by :created_at, :desc
      else
        with :complete, false
      end

      without :job_id, nil
      paginate page: params[:page] || 1
    end
      .results

    # We can't index on multiple values (scheduled dates of imprints) so we have to process the
    # scheduled_at query parameter manually.
    if q && !q[:scheduled_at].blank?
      wanted_date = q[:scheduled_at].to_date

      @imprintable_trains.select! do |imprintable_train|
        imprintable_train.imprints.pluck(:scheduled_at).any? { |sched| sched.to_date == wanted_date }
      end
    end
  end

end

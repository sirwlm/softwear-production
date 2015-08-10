class ImprintablesController < ApplicationController

  def index
    q = params[:q]
    @imprintable_trains = ImprintableTrain.search do
      if q
        fulltext q[:text] unless q[:text].blank?
        with :expected_arrival_date, q[:expected_arrival_date].to_date unless q[:expected_arrival_date].blank?
        with :state, q[:state] unless q[:state].blank?
      end

      without :job_id, nil
      paginate page: params[:page] || 1
    end
      .results
  end

end

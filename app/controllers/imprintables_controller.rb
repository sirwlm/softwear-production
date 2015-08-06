class ImprintablesController < ApplicationController

  def index
    @imprintable_trains = ImprintableTrain.all
  end

end

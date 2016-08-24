class ImprintableTrainsController < InheritedResources::Base
  
  def update
    @old_location = @imprintable_train.location
    @old_expected_date = @imprintable_train.expected_arrival_date

    update! do |success, failure|
      
    # success.js do
    #   render template: "trains/show"
    # end
    
    # failure.js do
    #   flash[:notice] = "Failed to update Imprintable Train: " + 
    #     @imprintable_train.errors.full_messages.join(", ") 
    #   render template: "trains/show"      
    # end

      success.json do
        location = params[:imprintable_train][:location]
        date = params[:imprintable_train][:expected_arrival_date]

        if location_changed?(location)
          create_location_changed_activity(@imprintable_train)
        elsif expected_date_changed?(date)
          create_expected_date_changed_activity(@imprintable_train)
        end
        
        render json: @imprintable_train
      end
      
      failure.json do
        render json: @imprintable_train
      end
    end
  end

  private 

  def location_changed?(location)
    if location
      @old_location != location
    else
      return false
    end
  end

  def expected_date_changed?(date)
    if date
      @old_expected_date.strftime("%Y-%m-%d") != date
    else
      return false
    end
  end

  def create_location_changed_activity(imprintable_train)
    @imprintable_train.create_activity(
      :transition,
      owner: current_user,
      parameters: { 
        event: "moved_inventory",
        location: @imprintable_train.location
      } 
    )
  end

  def create_expected_date_changed_activity(imprintable_train)
    @imprintable_train.create_activity(
      :transition,
      owner: current_user,
      parameters: {
        event: "changed_arrival_date",
        expected_arrival_date: @imprintable_train.expected_arrival_date.strftime("%Y %m %d %H:%M:%S")
      }
    )
  end

  def imprintable_train_params
    params.require(:imprintable_train).permit(:expected_arrival_date, :location)
  end

end

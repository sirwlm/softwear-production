class ImprintableTrainsController < InheritedResources::Base
  
  def update
    old_location = @imprintable_train.location
    old_expected_date = @imprintable_train.expected_arrival_date 
    
    update! do |success, failure|
      
      success.js do
        render template: "trains/show"
      end

      success.json do
        location = params[:imprintable_train][:location]
        date = params[:imprintable_train][:expected_arrival_date]

        if location_changed?(old_location)
          create_location_changed_activity(@imprintable_train)
        elsif expected_date_changed?(old_expected_date)
          create_expected_date_changed_activity(@imprintable_train)
        end
        
        render json: @imprintable_train
      end

      failure.js do
        flash[:notice] = "Failed to update Imprintable Train: " + 
          @imprintable_train.errors.full_messages.join(", ") 
        render template: "trains/show"      
      end

      failure.json do
        render json: @imprintable_train
      end
    end
  end

  private 

  def location_changed?(location)
    if location
      @imprintable_train.location != location
    else
      return false
    end
  end

  def expected_date_changed?(date)
    if date
      @imprintable_train.expected_arrival_date.strftime("%Y-%m-%d") != date
    else
      return false
    end
  end

  def create_location_changed_activity(imprintable_train)
    byebug
  end

  def create_expected_date_changed_activity(imprintable_train)
  end

  def imprintable_train_params
    params.require(:imprintable_train).permit(:expected_arrival_date, :location)
  end

end

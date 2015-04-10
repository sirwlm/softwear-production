namespace :screens do
  task dry: :environment do
    intervals = {
        reclaimed_and_drying: 15.minutes,
        coated_and_drying: 30.minutes,
        exposed_and_drying: 15.minutes
    }
    intervals.each do |state, interval|
      screens = Screen.where(state: state)
      screens.each do |screen|
        if Time.now - screen.updated_at > interval
          screen.dry
        end
      end
    end
  end
end
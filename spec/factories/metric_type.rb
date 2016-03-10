FactoryGirl.define do
  factory :metric_type do
    factory :metric_type_screen_print_start_count do
      name 'Screen Print Start Count'
      metric_type_class 'ScreenPrint'
      measurement_type 'count'
      activity 'print_started'
    end

    factory :metric_type_screen_print_print_time do
      name 'Screen Print Start Count'
      metric_type_class 'ScreenPrint'
      measurement_type 'timeframe'
      start_activity 'print_started'
      end_activity 'print_complete'
    end
  end
end


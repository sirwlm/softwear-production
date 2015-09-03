FactoryGirl.define do
  factory :blank_imprint, class: Imprint do
    name 'An Imprint'
    description 'An Imprint Description'
    type 'Print' 

    factory :imprint do
      scheduled_at Time.now
      count 1
      sequence(:estimated_time) { |n| n }
      machine { |imprint| imprint.association(:machine) }

      factory :print, class: Print do
        type 'Print'
      end
      
      factory :screen_print, class: ScreenPrint do
        type 'ScreenPrint'
      end
    end
  end
end

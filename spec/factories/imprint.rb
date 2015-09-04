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

      factory :button_making_print, class: ButtonMakingPrint do
        type 'ButtonMakingPrint'
      end

      factory :digital_print, class: DigitalPrint do
        type 'DigitalPrint'
      end

      factory :embroidery_print, class: EmbroideryPrint do
        type 'EmbroideryPrint'
      end

      factory :equipment_cleaning_print, class: EquipmentCleaningPrint do
        type 'EquipmentCleaningPrint'
      end

      factory :screen_print, class: ScreenPrint do
        type 'ScreenPrint'
      end

      factory :transfer_making_print, class: TransferMakingPrint do
        type 'TransferMakingPrint'
      end

      factory :transfer_print, class: TransferPrint do
        type 'TransferPrint'
      end
    end
  end
end

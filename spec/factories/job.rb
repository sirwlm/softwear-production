FactoryGirl.define do
  factory :job do
    name 'test job'
    imprints { [create(:print)] }


    factory :job_with_print do
      imprints { [create(:print)] }
    end

    factory :job_with_button_making_print do
      imprints { [create(:button_making_print)] }
    end

    factory :job_with_digital_print do
      imprints { [create(:digital_print)] }
    end

    factory :job_with_embroidery_print do
      imprints { [create(:embroidery_print)] }
    end

    factory :job_with_equipment_cleaning_print do
      imprints { [create(:equipment_cleaning_print)] }
    end

    factory :job_with_screen_print do
      imprints { [create(:screen_print)] }
    end

    factory :job_with_transfer_making_print do
      imprints { [create(:transfer_making_print)] }
    end

    factory :job_with_transfer_print do
      imprints { [create(:transfer_print)] }
    end
  end

end


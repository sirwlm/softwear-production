FactoryGirl.define do
  factory :order do
    name 'whatever'
    deadline 5.days.from_now
    jobs { create_list(:job, 1) }

    factory :order_with_print do 
      jobs { [create(:job_with_print)] } 
    end

  end
end

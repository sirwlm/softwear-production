FactoryGirl.define do
  factory :blank_screen, class: Screen do

    factory :screen do
      frame_type 'Panel'
      dimensions '23x21'
      mesh_type '110'
      state 'in_production'
      deleted_at nil
      created_at "2015-04-30 14:13:40"
      updated_at "2015-06-05 15:31:15"
    end

  end
end

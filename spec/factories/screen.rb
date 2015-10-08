FactoryGirl.define do
  factory :blank_screen, class: Screen do
    factory :screen do
      frame_type Screen::FRAME_TYPES.first
      dimensions Screen::DIMENSIONS.first
      mesh_type Screen::MESH_TYPES.first
      state :ready_to_expose
      deleted_at nil
      created_at "2015-04-30 14:13:40"
      updated_at "2015-06-05 15:31:15"
    end

  end
end

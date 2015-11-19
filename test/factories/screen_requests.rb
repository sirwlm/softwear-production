FactoryGirl.define do
  factory :screen_request do
    frame_type Screen::FRAME_TYPES.first
    mesh_type Screen::MESH_TYPES.first
    dimensions Screen::DIMENSIONS.first
    ink 'white base' 
  end

end

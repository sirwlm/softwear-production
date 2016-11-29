module Api
  class ConstantsController < Softwear::Library::ApiController
    CONSTANTS = {
      'screen_train/print_types' => ScreenTrain::PRINT_TYPES,
      'screen_train/difficulty'  => ScreenTrain::DIFFICULTY,

      'screen/mesh_types'  => Screen::MESH_TYPES,
      'screen/frame_types' => Screen::FRAME_TYPES,
      'screen/dimensions'  => Screen::DIMENSIONS
    }

    def index
      render json: CONSTANTS
    end

    def show
      render json: CONSTANTS[params[:const]]
    end
  end
end

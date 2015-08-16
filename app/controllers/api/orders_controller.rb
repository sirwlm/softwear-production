module Api
  class OrdersController < Softwear::Lib::ApiController

    private

    def includes
      [
        :pre_production_trains,
        :production_trains,
        :post_production_trains,
        jobs: {
          include: [
            :pre_production_trains,
            :production_trains,
            :post_production_trains,
            imprints: {
              only: [
                :scheduled_at, :estimated_time
              ],
              methods: [
                :completed?, :machine_name
              ]
            }
          ]
        }
      ]
    end
  end
end

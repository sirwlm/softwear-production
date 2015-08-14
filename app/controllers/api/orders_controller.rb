module Api
  class OrdersController < Softwear::Lib::ApiController

    private

    def includes
      [
        jobs: {
          include: {
            imprints: {
              only: [
                :state, :machine_name, :scheduled_at, :estimated_time,
                :completed?
              ]
            },
            imprintable_train: {
              only: [:state, :location]
            }
          }
        },
        fba_bagging_train: {
          only: [:state]
        },
        fba_label_train: {
          only: [:state]
        }
      ]
    end
  end
end

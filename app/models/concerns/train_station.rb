module TrainStation
  extend ActiveSupport::Concern

  def trains_of_type(type)
    trains = []
    Train.each_train_of_type(type, self, &trains.method(:<<))
    trains
  end

  %i(pre_production production post_production).each do |train_type|
    class_eval <<-RUBY, __FILE__, __LINE__
      def #{train_type}_trains
        trains_of_type(:#{train_type})
      end
    RUBY
  end
end

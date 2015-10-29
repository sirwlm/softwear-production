module TrainStation
  extend ActiveSupport::Concern

  def trains_of_type(type)
    t = []
    Train.each_train_of_type(type, self, &t.method(:<<))
    return_uniq t
  end

  def trains
    t = []
    Train.each_train(self, &t.method(:<<))
    return_uniq t
  end

  %i(pre_production production post_production).each do |train_type|
    class_eval <<-RUBY, __FILE__, __LINE__
      def #{train_type}_trains
        trains_of_type(:#{train_type})
      end
    RUBY
  end

  private

  def return_uniq(list)
    list.uniq { |t| "#{t.class.name}##{t.id}" }
  end
end

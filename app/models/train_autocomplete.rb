class TrainAutocomplete < ActiveRecord::Base
  def self.suggestions_for(train, field)
    where(field: "#{train.class.name}##{field}").pluck(:value)
  end
end

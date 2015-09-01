class TrainAutocomplete < ActiveRecord::Base
  def self.suggestions_for(train, field)
    if /^\w+\[(?<field_name>\w+)\]$/ =~ field
      field = field_name
    end
    where(field: "#{train.class.name}##{field}").pluck(:value)
  end
end

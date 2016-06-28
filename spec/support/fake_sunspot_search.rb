class FakeSunspotSearch
  attr_reader :results

  def initialize(*classes, &block)
    @results = classes.reduce([]) do |total, model|
      @model = model
      @query = @model.all
      @filters = []
      instance_eval(&block)

      total.concat(@filters.reduce(@query) { |list, f| f.call(list) })
    end
    self
  end

  def with(field, value)
    unless @model.column_names.include?(field.to_s)
      @filters << -> list { list.select { |x| x.send(field) == value } }
      return
    end

    if value.is_a?(Range)
      lt = value.exclude_end? ? '<' : '<='
      @query = @query.where(
        %[`#{field}` >= "#{value.min.to_s(:db)}" AND `#{field}` #{lt} "#{value.max.to_s(:db)}"]
      )
    else
      @query = @query.where(field => value)
    end
  end

  def paginate(*)
  end
end

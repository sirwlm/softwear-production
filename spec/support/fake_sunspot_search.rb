class FakeSunspotSearch
  attr_reader :results

  def initialize(*classes, &block)
    @results = classes.reduce([]) do |total, model|
      @model = model
      @query = @model.all
      instance_eval(&block)
      total.concat(@query)
    end
    self
  end

  def with(field, value)
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

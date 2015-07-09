class Order < ActiveRecord::Base
  # include CrmCounterpart
  has_many :jobs
  has_many :imprints, through: :jobs

  validates :name, :jobs,  presence: true

  accepts_nested_attributes_for :jobs, allow_destroy: true

  searchable do
    text :name, :job_names, :imprint_names, :imprint_descriptions
  end

  %w(job_names imprint_names imprint_descriptions).each do |name|
    split = name.split('_')

    class_eval <<-RUBY, __FILE__, __LINE__
      def #{name}
        #{split.first.pluralize}.pluck(:#{split.last.singularize}).join(' ')
      end
    RUBY
  end
end

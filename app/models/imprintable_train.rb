class ImprintableTrain < ActiveRecord::Base
  include PublicActivity::Model
  include Train

  SOLUTIONS = {
    need_to_order:           :ready_to_order,
    need_to_inventory:       :ordered,
    need_to_fully_inventory: :partially_inventoried,
  }
    .with_indifferent_access

  tracked only: [:transition]
  acts_as_warnable

  belongs_to :job
  has_one :order, through: :job
  has_many :imprints, through: :job

  searchable do
    text :job_name, :imprint_names, :location
    string :order_imprint_state do
      order.try(:imprint_state)
    end
    string :order_production_state do
      order.try(:production_state)
    end
    string :job_imprint_state do
      job.try(:imprint_state)
    end
    string :job_production_state do
      job.try(:production_state)
    end
    time(:expected_arrival_date) { |i| i.expected_arrival_date.try(:to_date) }
    time :created_at
    integer :job_id
  end

  attr_reader :solution
  attr_accessor :ordering_complete

  train_type :pre_production
  train initial: :ready_to_order, final: :inventoried do
    success_event :ordered, params: { expected_arrival_date: :date_field } do
      transition :ready_to_order => :ordered
    end

    success_event :partially_inventoried, params: { location: :text_field } do
      transition [:ordered, :partially_inventoried] => :inventoried
    end

    success_event :inventoried, params: { location: :text_field } do
      transition [:ordered, :partially_inventoried] => :inventoried
    end

    success_event :resolved_changes,
        params: { solution: SOLUTIONS.keys.map { |k| [k.to_s.humanize, k] } } do
      SOLUTIONS.each do |solution, state|
        transition :imprintable_changed => state, if: ->(i) { i.solution == solution.to_sym }
      end
      transition :imprintable_changed => same
    end

    delay_event :imprintable_line_items_changed do
      transition all - :imprintable_changed => :imprintable_changed
    end

    success_event :reset_state_machine do
      transition [:partially_ordered] => :ready_to_order
    end

    success_event :moved_inventory, params: { location: :text_field } do
      transition :inventoried => :inventoried
    end

    state :imprintable_changed, type: :delay
  end

  def solution=(s)
    @solution = s.to_sym
  end

  private

  def job_name
    job.try(:name)
  end

  def imprint_names
    imprints.pluck(:name).join(' ')
  end

  def order_name
    job.try(:order).try(:name)
  end
end

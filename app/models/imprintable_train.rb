class ImprintableTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  SOLUTIONS = {
    need_to_order:           :ready_to_order,
    need_to_fully_order:     :partially_ordered,
    need_to_inventory:       :ordered,
    need_to_fully_inventory: :partially_inventoried,
    need_to_stage:           :inventoried,
    need_to_print:           :staged
  }
    .with_indifferent_access

  tracked only: [:transition]

  belongs_to :job
  has_one :order, through: :job
  has_many :imprints, through: :job

  searchable do
    text :job_name, :imprint_names, :order_name, :human_state_name, :location
    string :state
    time(:expected_arrival_date) { |i| i.expected_arrival_date.try(:to_date) }
    integer :job_id
  end

  before_save :check_solution

  attr_accessor :solution

  train_type :pre_production
  train initial: :ready_to_order, final: :staged do
    success_event :some_pieces_ordered,
        params:          { location: :text_field, expected_arrival_date: :date_field },
        public_activity: { supplier: :text_field } do
      transition [:ready_to_order, :partially_ordered] => :partially_ordered
    end

    success_event :all_pieces_ordered,
        params:          { location: :text_field, expected_arrival_date: :date_field },
        public_activity: { supplier: :text_field } do
      transition [:ready_to_order, :partially_ordered] => :ordered
    end

    success_event :some_pieces_arrive, params: { location: :text_field } do
      transition [:ordered, :partially_inventoried] => :partially_inventoried
    end

    success_event :all_pieces_arrived, params: { location: :text_field } do
      transition [:ordered, :partially_inventoried] => :inventoried
    end

    success_event :pieces_on_cart, params: { location: :text_field } do
      transition :inventoried => :staged
    end

    success_event :resolved_changes,
        params: { solution: SOLUTIONS.keys.map { |k| [k.to_s.humanize, k] } } do
      transition :imprintable_changed => :ready_to_order
    end

    delay_event :imprintable_line_items_changed do
      transition all - :imprintable_changed => :imprintable_changed
    end

    delay_event :moved_back_to_inventory, params: { location: :text_field } do
      transition :staged => :inventoried
    end

    state :imprintable_changed, type: :delay
  end

  private

  def check_solution
    return if @solution.nil?
    new_state = SOLUTIONS[@solution]

    update_column :state, new_state unless new_state.nil?
    @solution = nil
  end

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

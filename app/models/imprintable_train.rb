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

  attr_accessor :solution

  before_save :check_solution

  train_type :pre_production
  train initial: :ready_to_order do
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

    success_event :some_pieces_arrive do
      transition [:ordered, :partially_inventoried] => :partially_inventoried
    end

    success_event :all_pieces_arrived do
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

    state :partially_ordered
    state :ready_to_order
    state :ordered
    state :partially_inventoried
    state :inventoried
    state :staged
    state :imprintable_changed
  end

  private

  def check_solution
    return if @solution.nil?

    update_column :state, SOLUTIONS[@solution]
    @solution = nil
  end
end

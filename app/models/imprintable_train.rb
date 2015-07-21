class ImprintableTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  tracked only: [:transition]

  attr_accessor :solution

  belongs_to :job

  train_type :pre_production
  train initial: :ready_to_order do

    success_event :some_pieces_ordered, public_activity: { supplier: :text_field, location: :text_field, estimated_arrival_date: :text_field } do
      transition [:ready_to_order, :partially_ordered] => :partially_ordered
    end

    success_event :all_pieces_ordered do
      transition [:ready_to_order, :partially_ordered] => :ordered
    end

    success_event :some_pieces_arrive, public_activity: { input: :text_field, location: :text_field } do
      transition [:ordered, :partially_inventoried] => :partially_inventoried
    end

    success_event :all_pieces_arrived, public_activity: { input: :text_field, location: :text_field } do
      transition [:ordered, :partially_inventoried] => :inventoried
    end

    success_event :pieces_on_cart, public_activity: { input: :text_field, location: :text_field } do
      transition :inventoried => :staged
    end

    success_event :resolved_imprintable_change do
      # TODO: check out these @solutions, are they right?
      transition :imprintable_changed => :ready_to_order,        if: ->(it){ it.solution == 'need_to_order' }
      transition :imprintable_changed => :partially_ordered,     if: ->(it){ it.solution == 'need_to_fully_order' }
      transition :imprintable_changed => :ordered,               if: ->(it){ it.solution == 'need_to_inventory' }
      transition :imprintable_changed => :partially_inventoried, if: ->(it){ it.solution == 'need_to_fully_inventory' }
      transition :imprintable_changed => :inventoried,           if: ->(it){ it.solution == 'need_to_stage' }
      transition :imprintable_changed => :staged,                if: ->(it){ it.solution == 'need_to_print' }
      # avoid a default transition here to expose an incorrect @solution to the user
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

  def resolved_imprintable_change(solution)
    @solution = solution
    super
  end
end

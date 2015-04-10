class Screen < ActiveRecord::Base

  INITIAL_STATES = %w(new broken ready_to_reclaim ready_to_coat ready_to_expose ready_to_tape in_production)
  MESH_TYPES = %w(24 80 110 110s 135s 140 150s 156 160 180s 196 200s 225s 230 270 305)
  FRAME_TYPES = %w(Roller Panel Static)
  DIMENSIONS = %w(22x31 25x36 )

  validates_presence_of :dimensions, :frame_type, :state
  validates_presence_of :mesh_type, unless: -> {"state == 'new'"}

  state_machine :state do

    event :mesh do
      transition [:new, :broken] => :ready_to_reclaim
    end

    event :reclaimed do
      transition :ready_to_reclaim => :reclaimed_and_drying
    end

    event :coat do
      transition :ready_to_coat => :coated_and_drying
    end

    event :expose_and_rinse do
      transition :ready_to_expose => :exposed_and_drying
    end

    event :tape do
      transition :ready_to_tape => :in_production
    end

    event :remove_tape_and_ink do
      transition :in_production => :ready_to_reclaim
    end

    event :dryed do
      transition :reclaimed_and_drying => :ready_to_coat
      transition :coated_and_drying => :ready_to_expose
      transition :exposed_and_drying => :ready_to_tape
    end

    event :broke do
      transition any => :broken
    end

    event :bad_prep do
      transition [:reclaimed_and_drying, :ready_to_coat, :coated_and_drying, :ready_to_expose, :exposed_and_drying, :ready_to_tape, :in_production] => :ready_to_reclaim
    end

  end

end

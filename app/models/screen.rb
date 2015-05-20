class Screen < ActiveRecord::Base
  include PublicActivity::Model
  tracked only: [:transition]

  INITIAL_STATES = %w(new broken ready_to_reclaim ready_to_coat ready_to_expose ready_to_tape in_production)
  MESH_TYPES = %w(24 80 110 110s 135s 140 150s 156 160 180s 196 200s 225s 230 270 305)
  FRAME_TYPES = %w(Roller Panel Static)
  DIMENSIONS = %w(22x31 25x36)
  SCREEN_BREAK_REASONS = [
    'Checking tension / dropped tension meter on it',
    'Overtensioning',
    'Retensioning Used Mesh',
    'Replacing Tape',
    'Checking tension / dropped tension meter on it',
    'Overtensioning',
    'Replacing Tape (no tensioning)',
    'Removing Tape',
    'Loading/removing from Dip Tank',
    'Scrubbing screen',
    'Power washing - sprayed too close / hit with power washer',
    'Loading into Drying Rack',
    'Removing tape (At Ink Removal Time',
    'Removing ink',
    'Damaged by emulsion trough',
    'While loading into Uni-Kote',
    'Loading/unloading CTS',
    'Loading/unloading Exposure',
    'Loading/removing from Dip Tank',
    'Washing out stencil - sprayed too close / hit with power washer',
    'Taping/checking for pinholes',
    'During printing',
    'Loading ink into screen',
    'Squeegee left unlocked',
    'Flood Bar left unlocked',
    'Didnt tape button area',
    'Loading/Unloading Flood Bar',
    'Loading/Unloading Squeegee',
    'Careless handling - Dropped screen',
    'Careless handling - bumped into something',
    'Other'
  ]

  SCREEN_BAD_PREP_REASONS = [
    'Incomplete Reclaim - emulsion/ink still on mesh',
    'Incomplete Reclaim - frame not sufficiently clean',
    'Incomplete Reclaim - emulsion/ink still on mesh',
    'Incomplete Reclaim - frame not sufficiently clean',
    'Improper Coating',
    'Bad Washout - stencil not completely washed out',
    'Bad Washout - stencil damaged'
    ]

  validates_presence_of :dimensions, :frame_type, :state
  validates_presence_of :mesh_type, unless: -> {"state == 'new'"}

  state_machine :state do

    event :meshed do
      transition [:new, :broken] => :ready_to_reclaim
    end

    event :reclaimed do
      transition :ready_to_reclaim => :reclaimed_and_drying
    end

    event :coated do
      transition :ready_to_coat => :coated_and_drying
    end

    event :expose_and_rinse do
      transition :ready_to_expose => :exposed_and_drying
    end

    event :taped do
      transition :ready_to_tape => :in_production
    end

    event :removed_tape_and_ink do
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
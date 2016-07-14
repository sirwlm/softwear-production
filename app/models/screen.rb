class Screen < ActiveRecord::Base
  include PublicActivity::Model

  tracked only: [:transition]

  INITIAL_STATES = %w(new broken ready_to_reclaim ready_to_coat ready_to_expose in_production)
  MESH_TYPES = %w(24 80 110 110s 135s 140 150s 156 160 180s 196 200s 225s 230 280 305)
  FRAME_TYPES = %w(Roller Panel Static)
  DIMENSIONS = %w(23x31 25x36)
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
    'Heating Cabinet Failure',
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
  
  has_many :assigned_screens
  has_many :imprints, through: :assigned_screens

  validates :dimensions, :frame_type, :state, presence: true
  validates :mesh_type, presence: true, unless: -> {"state == 'new'"}
  validates :id, uniqueness: true

  attr_accessor :just_assigned

  after_initialize :assign_id

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

    event :exposed do
      transition :ready_to_expose => :washed_out_and_drying
    end

    event :removed_from_production do
      transition :in_production => :ready_to_reclaim
    end

    event :dryed do
      transition :reclaimed_and_drying => :ready_to_coat
      transition :coated_and_drying => :ready_to_expose
      transition :washed_out_and_drying => :in_production
    end

    event :broke do
      transition any => :broken
    end

    event :bad_prep do
      transition [:reclaimed_and_drying, :ready_to_coat, :coated_and_drying, :ready_to_expose, :washed_out_and_drying, :in_production] => :ready_to_reclaim
    end
  end

  def self.dry_screens
    intervals = {
        reclaimed_and_drying: 1.hour,
        coated_and_drying: 30.minutes,
        washed_out_and_drying: 10.minutes
    }
    intervals.each do |state, interval|
      screens = Screen.where(state: state)
      screens.each do |screen|
        if Time.now - screen.updated_at > interval
          screen.dryed
        end
      end
    end
  end
  
  def current_imprints
    imprints.reject{ |x| x.complete? }
  end

  private

  def assign_id
    self.id = (Screen.maximum(:id) || 0) + 1 unless (self.id? && Screen.count > 0)
  end

  def self.list_states
    Screen.state_machine.states.map &:name
  end

end

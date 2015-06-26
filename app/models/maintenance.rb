class Maintenance < ActiveRecord::Base
  include ColorUtils
  include Schedulable

  validates :machine, presence: { message: 'must be present in order to schedule a maintenance', allow_blank: false }, if: :scheduled?
  validates :name, :description, presence: true

  searchable do
    text :name, :description
    integer :completed_by_id
    boolean :complete do
      completed?
    end
    time :scheduled_at
    time :completed_at
    boolean :scheduled do
      !scheduled_at.nil?
    end
    integer :machine_id
  end

  def display
    "(MAINTENANCE)#{' (COMPLETE)' if completed?} #{name}"
  end

  def calendar_color
    completed? ? 'white' : 'black'
  end

  def text_color
    completed? ? 'black' : 'white'
  end

  def border_color
    nil
  end
end

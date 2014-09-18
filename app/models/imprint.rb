class Imprint < ActiveRecord::Base
  # Scopes

  # Constants

  # attr macros

  # followed by association macros
  belongs_to :machine

  # validation macros
  validates :machine, presence: true, allow_blank: false, if: :scheduled?

  # callbacks

  # other macros (like devise's)

  def estimated_end_at
    scheduled_at + estimated_time.hours rescue nil
  end

  def scheduled?
    !scheduled_at.blank?
  end

  def machine_name
    machine.name rescue 'Not Assigned'
  end

  private

end

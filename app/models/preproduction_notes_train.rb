class PreproductionNotesTrain < ActiveRecord::Base
  include Train
  include PublicActivity::Model

  tracked only: [:transition]

  belongs_to :job
  has_one :order, through: :job

  validate :manager_password_correct

  attr_accessor :manager_id
  attr_writer :manager_password

  train_type :pre_production
  train initial: :pending_notes, final: :acknowledged do
    before_transition on: :approve, do: :validate_approval

    success_event :pending_review do
      transition :pending_notes => :pending_review
    end

    success_event :approve,
        params: {
          manager_id: -> { User.managers.map { |u| [u.email, u.id] } },
          manager_password: :password_field
        } do
      transition :pending_review => :approved
    end

    success_event :acknowledge do
      transition :approved => :acknowledged
    end
  end

  def validate_approval
    manager = User.find(@manager_id)
    if !manager.valid_password?(@manager_password)
      @manager_error = "is incorrect"
    end

  ensure
    @manager_id = nil
    @manager_password = nil
  end

  protected

  def manager_password_correct
    return if @manager_error.nil?

    errors.add(:manager_password, @manager_error)
    @manager_error = nil
  end
end

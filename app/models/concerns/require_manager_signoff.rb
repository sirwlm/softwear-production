module RequireManagerSignoff
  extend ActiveSupport::Concern

  included do
    validate :manager_password_correct

    attr_accessor :manager_id
    attr_writer :manager_password

    dont_track :manager_password

    def self.requires_manager_signoff
      {
        params: {
          manager_id: -> { User.managers.pluck(:email, :id) },
          manager_password: :password_field
        }
      }
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

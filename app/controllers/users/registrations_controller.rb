class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      resource.confirm!
    end
  end

  def update
    super do |resource|
    #   TODO: find some way to flash custom message here, since the default messages don't appear to be showing
    #   https://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb
    #   use that as a reference, I wasn't sure how to go about it...
    end
  end
end

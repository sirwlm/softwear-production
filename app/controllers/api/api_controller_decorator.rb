Softwear::Library::ApiController.class_eval do
  token_authenticate User if Rails.env.production?
end

# handles basic authentication for the services controller
module BasicAuthenticationHelper

  protected
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials[:service_username] && password == Rails.application.credentials =[:service_password]
    end
  end
end
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include Pundit::Authorization
  include ApplicationHelper

  before_action :signed_in_user, except: :access_determination
  around_action :scope_current_username
  before_action :set_browser_no_cache
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def true?(obj)
    obj.to_s.downcase == "true"
  end

  private
  def scope_current_username
    User.current_username = current_username
    yield
  ensure
    User.current_username = nil
  end

  def user_not_authorized(exception)
    flash[:warning] = "You are not authorized to #{meaningful_action_name(action_name).humanize.downcase} #{controller_name.humanize.split.map(&:capitalize)*' '}"
    redirect_to request.referrer || root_path
  end

  private
  def set_browser_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end

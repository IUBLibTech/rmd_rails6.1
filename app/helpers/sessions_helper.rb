module SessionsHelper
  def sign_in(username)
    self.current_username = username
    User.save_session_user(username)
  end

  def current_username=(username)
    session[:username] = username
  end

  def current_username
    session[:username]
  end

  def current_username?(username)
    session[:username] == username
  end

  # provided for compatibility with pundit
  def current_user
    session[:username]
  end

  def signed_in_user
    unless signed_in?
      redirect_to signin_url
    end
  end

  def signed_in?
    !current_username.nil?
  end

  def sign_out
    self.current_username = nil
  end

  def redirect_back_or_to(default=root_url)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

end
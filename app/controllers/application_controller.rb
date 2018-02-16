class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def user_signed_in?
    !!current_user
  end
  helper_method :user_signed_in?

  private

  def current_user=(user)
    @current_user = user
    session[:user_id] = user&.id
  end
end

class SessionsController < ApplicationController
  def create
    self.current_user = User.find_or_create_with_auth_hash!(auth_hash)
    redirect_to :root, notice: t('sessions.signed_in')
  end

  def failure
    redirect_to :root, alert: t('sessions.failure')
  end

  def destroy
    self.current_user = nil
    redirect_to :root, alert: t('sessions.signed_out')
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end

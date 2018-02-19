class WelcomeController < ApplicationController
  def index
    return unless user_signed_in?
    @md = current_user.to_md(
      params[:link].to_i == 1,
      params[:no_category].to_i != 1,
    )
  end
end

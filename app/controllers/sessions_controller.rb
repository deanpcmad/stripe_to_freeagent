class SessionsController < ApplicationController
  def create
  	# raise request.env["omniauth.auth"].to_yaml
    account = FreeagentAccount.from_omniauth(current_user, env["omniauth.auth"])
    # session[:user_id] = user.id
    redirect_to root_url(complete: true)
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
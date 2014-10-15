class SessionsController < ApplicationController
  def create
  	# raise request.env["omniauth.auth"].to_yaml
  
    if params[:provider] == "freeagent"
      account = FreeagentAccount.from_omniauth(current_user, env["omniauth.auth"])
    elsif params[:provider] == "stripe_connect"
      account = StripeAccount.from_omniauth(current_user, env["omniauth.auth"])
    end

    redirect_to root_url(complete: true)
  end

  def destroy
    reset_session
    redirect_to root_url
  end
end
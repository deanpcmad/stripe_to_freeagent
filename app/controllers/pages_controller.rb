class PagesController < ApplicationController
  def home
  end

  def setup_stripe
  	if request.patch?
  	  params = {
  	    scope: 'read_write',
  	    redirect_uri: setup_stripe_url,
  	    state: current_user.token
  	  }

  	  # Redirect the user to the authorize_uri endpoint
  	  redirect_to STRIPE_CONNECT.auth_code.authorize_url(params)
  	elsif request.get?
      begin
  			# Pull the authorization_code out of the response
  	    code = request.params[:code]
    		user = User.find_by(token: request.params[:state])
    		 
  	    # Make a request to the access_token_uri endpoint to get an access_token
  	    response = STRIPE_CONNECT.auth_code.get_token(code, params: {scope: "read_write"})

  	    # Create a StripeAcount for the user
  	    acc = StripeAccount.new(user: user)
  	    acc.token = response.token
  	    acc.publishable_key = response.params["stripe_publishable_key"]
  	    acc.stripe_user_id = response.params["stripe_user_id"]

  	    # If saving the acc is successful then redirect to root
  	    if acc.save
  		    redirect_to root_url(complete: true)
  		  else
  		  	redirect_to root_url(complete: false)
  		  end
      rescue => e
        render text: "Error -- #{e}"
      end

  	elsif request.delete?
  	  current_account.stripe_token = nil
  	  current_account.stripe_publishable_key = nil
  	  current_account.stripe_user_id = nil
  	  current_account.save
  	  
  	  redirect_to settings_stripe_path, notice: "Stripe successfully disabled"
  	end
  end
end

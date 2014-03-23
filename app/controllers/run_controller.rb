class RunController < ApplicationController

	before_filter :authenticate_user!

	def go
		if current_user.freeagent_account.present? && current_user.stripe_account.present?
			if current_user.freeagent_account.main.present? && current_user.freeagent_account.stripe.present?
				log = current_user.logs.create(content: "")
				Resque.enqueue(Run, current_user.id, log.id)
				redirect_to log_path(log), notice: "Import started. Below is the log for it."
			else
				redirect_to edit_freeagent_account_path(current_user.freeagent_account), alert: "You need to set your Main & Stripe account IDs"
			end
		else
			redirect_to root_path, alert: "You don't have a FreeAgent or Stripe account linked"
		end		
	end

end
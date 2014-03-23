class FreeagentAccountsController < ApplicationController

	before_filter :authenticate_user!

	before_action {
		@freeagent_account = current_user.freeagent_account
	}

	def edit
		render action: "_form"
	end

	def update
		if @freeagent_account.update_attributes(fa_params)
			redirect_to root_path, notice: "Updated FreeAgent Account"
		else
			render "_form"
		end
	end

	private

	def fa_params
		params.require(:freeagent_account).permit(:main, :stripe)
	end

end
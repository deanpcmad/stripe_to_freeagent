class StripeAccountsController < ApplicationController
  
  before_action {
    @stripe_account = current_user.stripe_accounts.find(params[:id])
  }

  def edit
    render action: "_form"
  end

  def update
    if @stripe_account.update_attributes(fa_params)
      redirect_to root_path, notice: "Updated Stripe Account"
    else
      render "_form"
    end
  end

  private

  def fa_params
    params.require(:stripe_account).permit(:label, :import_from)
  end

end
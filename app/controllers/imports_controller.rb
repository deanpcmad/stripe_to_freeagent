class ImportsController < ApplicationController

  def index
    @imports = current_user.imports.to_a
  end

  def show
    @import = current_user.imports.find_by!(token: params[:id])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @import = current_user.imports.build(import_params)
    @import.log = ""
    if @import.save
      Resque.enqueue(ImportWorker, current_user.id, @import.id)
      redirect_to import_path(@import.token), notice: "Import started. Below is the log for it."
    end
  end

  def update
    if @freeagent_account.update_attributes(fa_params)
      redirect_to root_path, notice: "Updated FreeAgent Account"
    else
      render "_form"
    end
  end

  private

  def import_params
    params.require(:import).permit(:stripe_account_id, :freeagent_account_id)
  end

end
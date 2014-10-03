class AddLabelToStripeAccounts < ActiveRecord::Migration
  def change
    add_column :stripe_accounts, :label, :string
  end
end

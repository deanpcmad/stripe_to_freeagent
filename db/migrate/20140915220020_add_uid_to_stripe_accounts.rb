class AddUidToStripeAccounts < ActiveRecord::Migration
  def change
    add_column :stripe_accounts, :uid, :string
  end
end

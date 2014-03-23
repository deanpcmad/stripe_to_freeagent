class AddLastUpdatedToStripeAccounts < ActiveRecord::Migration
  def change
    add_column :stripe_accounts, :last_updated, :datetime
  end
end

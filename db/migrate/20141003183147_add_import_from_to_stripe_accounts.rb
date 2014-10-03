class AddImportFromToStripeAccounts < ActiveRecord::Migration
  def change
    add_column :stripe_accounts, :import_from, :datetime
  end
end

class AddAccountNumbersToFreeagentAccounts < ActiveRecord::Migration
  def change
    add_column :freeagent_accounts, :stripe, :integer
    add_column :freeagent_accounts, :main, :integer
  end
end

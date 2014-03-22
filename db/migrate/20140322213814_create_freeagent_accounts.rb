class CreateFreeagentAccounts < ActiveRecord::Migration
  def change
    create_table :freeagent_accounts do |t|
      t.belongs_to :user, index: true
      t.string :uid
      t.string :email
      t.string :token
      t.string :refresh_token
      t.integer :expires_at

      t.timestamps
    end
  end
end

class CreateStripeAccounts < ActiveRecord::Migration
  def change
    create_table :stripe_accounts do |t|
      t.belongs_to :user, index: true
      t.string :token
      t.string :publishable_key
      t.string :stripe_user_id

      t.timestamps
    end
  end
end

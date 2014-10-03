class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.belongs_to :user, index: true
      t.belongs_to :stripe_account, index: true
      t.belongs_to :freeagent_account, index: true
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end

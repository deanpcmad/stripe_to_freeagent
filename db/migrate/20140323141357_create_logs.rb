class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.belongs_to :user, index: true
      t.text :content
      t.boolean :success, default: false

      t.timestamps
    end
  end
end

class AddTokenToImports < ActiveRecord::Migration
  def change
    add_column :imports, :token, :string
  end
end

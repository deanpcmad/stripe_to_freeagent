class AddSuccessToImports < ActiveRecord::Migration
  def change
    add_column :imports, :success, :boolean, default: false
  end
end

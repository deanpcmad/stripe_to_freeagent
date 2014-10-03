class AddLogToImports < ActiveRecord::Migration
  def change
    add_column :imports, :log, :text
  end
end

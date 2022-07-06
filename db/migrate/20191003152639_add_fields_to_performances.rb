class AddFieldsToPerformances < ActiveRecord::Migration[4.2]
  def change
    add_column :performances, :title, :string unless column_exists? :performances, :title
    add_column :performances, :notes, :text unless column_exists? :performances, :notes
  end
end

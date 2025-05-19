class AddBIbha < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :b_ibha, :boolean unless column_exists? :users, :b_ibha
  end
end

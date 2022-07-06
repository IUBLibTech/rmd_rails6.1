class AddMiddleNameToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :middle_name, :string
  end
end

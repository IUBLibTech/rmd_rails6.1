class AddModifiedInMcoToAvalonItem < ActiveRecord::Migration[4.2]
  def up
    add_column :avalon_items, :modified_in_mco, :boolean, default: false
    AvalonItem.all.update_all(modified_in_mco: false)
  end

  def down
    remove_column :avalon_items, :modified_in_mco
  end
end

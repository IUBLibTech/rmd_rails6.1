class AddCollectionToAvalonItem < ActiveRecord::Migration[4.2]
  def change
    add_column :avalon_items, :collection, :text
  end
end

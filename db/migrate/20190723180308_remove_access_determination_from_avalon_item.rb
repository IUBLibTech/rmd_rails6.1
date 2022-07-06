class RemoveAccessDeterminationFromAvalonItem < ActiveRecord::Migration[4.2]
  def change
    remove_column :avalon_items, :access_determination
  end
end

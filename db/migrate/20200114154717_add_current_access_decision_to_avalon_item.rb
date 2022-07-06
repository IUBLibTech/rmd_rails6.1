class AddCurrentAccessDecisionToAvalonItem < ActiveRecord::Migration[4.2]
  def change
    add_column :avalon_items, :current_access_determination_id, :integer, limit: 8
  end
end

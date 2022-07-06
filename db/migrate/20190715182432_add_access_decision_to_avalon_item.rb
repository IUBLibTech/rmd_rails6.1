class AddAccessDecisionToAvalonItem < ActiveRecord::Migration[4.2]
  def change
    add_column :avalon_items, :access_determination, :string, default: Recording::DEFAULT_ACCESS
  end
end

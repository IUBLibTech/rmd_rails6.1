class AddFedoraItemIdToRecordings < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :fedora_item_id, :string
  end
end

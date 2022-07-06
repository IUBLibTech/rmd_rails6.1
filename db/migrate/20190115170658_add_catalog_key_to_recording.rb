class AddCatalogKeyToRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :catalog_key, :text
  end
end

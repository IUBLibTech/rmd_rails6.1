class CreateAtomFeedReads < ActiveRecord::Migration[4.2]
  def change
    create_table :atom_feed_reads do |t|
      t.text :title, null: false
      t.datetime :avalon_last_updated, null: false
      t.string :json_url, null: false
      t.string :avalon_item_url, null: false
      t.string :avalon_id, null: false
      t.boolean :successfully_read, default: false
      t.timestamps null: false
    end
    add_index :atom_feed_reads, :avalon_id, unique: true
  end
end

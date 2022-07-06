class AddAtomFeedReadToRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :atom_feed_read_id, :integer, limit: 8
  end
end

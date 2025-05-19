class AddAtomFeedTimestamps < ActiveRecord::Migration[6.1]
  def change
    # the timestamp when a NEW AtomFeedRead is discovered in the atom feed
    add_column :atom_feed_reads, :atom_feed_new_timestamp, :datetime
    # the most recent timestamp when an EXISTING AtomFeedRead
    add_column :atom_feed_reads, :atom_feed_update_timestamp, :datetime
    # the most recent timestamp when the JSON record was parsed for this AtomFeedRead
    add_column :atom_feed_reads, :json_last_parse_timestamp, :datetime
  end
end

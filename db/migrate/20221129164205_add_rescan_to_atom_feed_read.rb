class AddRescanToAtomFeedRead < ActiveRecord::Migration[6.1]

  def change
    add_column :atom_feed_reads, :rescan, :boolean
  end

end

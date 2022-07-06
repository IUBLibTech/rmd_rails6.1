class AddEntryXmlToAtomFeedRead < ActiveRecord::Migration[4.2]
  def change
    add_column :atom_feed_reads, :entry_xml, :text
  end
end

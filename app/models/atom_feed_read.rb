class AtomFeedRead < ApplicationRecord

  # The atom feed should be search in descending avalon_last_updated timestamp order so that each read continues
  # only as long as "new/changed" items are encountered: look at feed <updated> timestamp compared to the most recent
  # AtomFeedRead.avalon_last_updated timestamp. Anything more recent than that timestamp is either a new item
  # (no AFR object), or is an existing AFR object which has changed in Avalon since it was last encountered in the feed
  # (<updated> will be greater than item.avalon_last_updated)
  #
  # @deprecated atom_feed_new_timestamp and atom_feed_update_timestamp should no longer be used, and once RMD feels
  # properly sync'd with MCO, these fields should be dropped from the table


  # Returns the DateTime of the most recent AtomFeedRead.avalon_last_updated value. Use when parsing the
  # atom feed to cease when existing-but-not-updated AtomFeedReads are reached.
  def self.stop_timestamp
    AtomFeedRead.order(:avalon_last_updated).first.avalon_last_updated
  end

  def mco_id
    # converts the avalon_id from JSON which is actually a URL like https://mco-staging.dlib.indiana.edu/media_objects/gb19f9998
    # into just the ID portion of the URL: gb19f9998 in this case
    avalon_id.split('/').last
  end

  # Alias for avalon_last_updated - the timestamp reported in the Atom Feed when this AFR was LAST READ
  def last_read
    avalon_last_updated
  end


end

class AtomFeedReaderTask
  include AfrHelper
  include Delayed::RecurringJob

  run_every 1.hour
  run_at Time.now
  queue 'feed-reader'

  def perform
    LOGGER.info("AtomFeedReaderTask#perform - checking for new records")
    # see AfrHelper for this
    read_atom_feed
  end


end
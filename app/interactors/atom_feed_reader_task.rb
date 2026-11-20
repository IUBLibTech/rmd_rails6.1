class AtomFeedReaderTask
  include AfrHelper
  include Delayed::RecurringJob

  run_every 10.minutes
  run_at Time.now
  queue 'feed-reader'

  def perform
    LOGGER.info("AtomFeedReaderTask#perform - checking for new/updated MCO content")
    # see AfrHelper for this
    read_atom_feed2(false)
  end

end
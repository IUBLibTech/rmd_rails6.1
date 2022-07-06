class AtomFeedReaderTask
  include Delayed::RecurringJob
  include AfrHelper

  timezone 'US/Eastern'
  run_every 1.hour
  run_at Time.now
  queue 'feed-reader'

  def perform
    # see AfrHelper for this
    read_atom_feed
  end


end
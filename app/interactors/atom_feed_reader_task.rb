class AtomFeedReaderTask
  include AfrHelper
  include Delayed::RecurringJob

  run_every 1.hour
  run_at '11:00am'
  queue 'feed-reader'

  def perform
    # see AfrHelper for this
    read_atom_feed
  end


end
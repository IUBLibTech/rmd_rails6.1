class JsonReaderTask
  include Delayed::RecurringJob
  include JsonReaderHelper

  timezone 'US/Eastern'
  run_every 1.hour
  run_at Time.now
  queue 'json-reader'

  def perform
    # see JsonReaderHelper for this
    read_json
  end

end
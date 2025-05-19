class JsonReaderTask
  include Delayed::RecurringJob
  include JsonReaderHelper

  LOGGER = Logger.new("#{Rails.root}/log/json_reader_task.log", 10, 10.megabytes)

  run_every 10.minutes
  run_at Time.now
  queue 'json-reader'

  def perform
    LOGGER.info("JSonReadTask#perform - checking for JSON records")
    # see JsonReaderHelper for this
    read_json
  end

end
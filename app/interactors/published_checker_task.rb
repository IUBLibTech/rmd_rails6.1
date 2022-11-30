class PublishedChecker
  include Delayed::RecurringJob
  include AtomFeedReaderHelper

  run_every 10.minutes
  run_at Time.now
  queue 'published-checker'

  def perform
    LOGGER.info("PublishedChecker#perform - checking for newly published records in MCO")
    ais = AvalonItem.unpublished
    Logger.info("PublishedChecker#perform - found #{ais.size} AvalonItems")
    ais.each_with_index do |ai, i|
      Logger.info("\t\tPublishedChecker#perform - Checking #{i+1} of #{ais.size}")
      # if this fails, the call does the bookkeeping of updating the AtomFeedRead to failure status
      if read_json ai
        json = JSON.parse ai.json
        ai.update!(published_in_mco: json["published"])
      end
    end
  end

end

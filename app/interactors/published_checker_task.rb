class PublishedCheckerTask
  include Delayed::RecurringJob
  LOGGER = Logger.new("#{Rails.root}/log/published_checker_task.log")

  # run_every 10.minutes
  # run_at Time.now
  # queue 'published-checker'

  def perform
    LOGGER.info("PublishedChecker#perform - checking for newly published records in MCO")
    ais = AvalonItem.unpublished
    LOGGER.info("PublishedChecker#perform - found #{ais.size} AvalonItems")
    ais.each_with_index do |ai, i|
      puts "Checking Checking #{i+1} of #{ais.size}"
      LOGGER.info("\t\tPublishedChecker#perform - Checking #{i+1} of #{ais.size}")
      # if this fails, the call does the bookkeeping of updating the AtomFeedRead to failure status
      response = read_json ai
      if response.kind_of? Net::HTTPSuccess
        json = JSON.parse(response.body)
        puts "Successfully read JSON"
        published = json["published"]
        ai.published_in_mco = published
        ai.save!
      else
        LOGGER.warn "Failed to retrieve JSON from MCO for AvalonItem id:#{ai.id}"
        ai.atom_feed_read.update(json_failed: true, json_error_message: "MCO JSON request returned #{something} for #{uri}")
      end
    end
    puts "Done!"
  end

  private
  def read_json(ai)
    uri = URI.parse ai.atom_feed_read.json_url
    puts "Reading MCO JSON: #{uri.to_s}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Avalon-Api-Key'] = Rails.application.credentials[:avalon_token]
    http.request(request)
  end

end

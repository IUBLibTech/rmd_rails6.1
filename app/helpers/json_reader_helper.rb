module JsonReaderHelper
  require 'nokogiri'
  require 'net/http'
  require 'uri'
  include AvalonItemsHelper

  LOGGER ||= Logger.new("#{Rails.root}/log/json_reader_delayed_job")
  READ_TIMEOUT_SECONDS = 180

  def read_json
    LOGGER.info "Checking for new JSON records"
    unread = AtomFeedRead.where(successfully_read: false, json_failed: false)
    LOGGER.info "#{unread.size} new JSON records to read"
    unread.each_with_index do |afr, i|
      AtomFeedRead.transaction do
        begin
          LOGGER.info "Reading #{i + 1} of #{unread.size} JSON records"
          load_single(afr)
        rescue => error
          if error.is_a? Net::ReadTimeout
            # In the event of a timeout, set the error message but leave the json_failed flag set to false. This will
            # identify any problematic records (the error message) but ALSO allow for subsequent re-attempts at
            # reading the record into RMD
            afr.update(successfully_read: false, json_failed: false, json_error_message: "The HTTP get request timed out after #{READ_TIMEOUT_SECONDS} seconds")
          else
            msg = "Raised an Exception: #{error.message}\n#{error.backtrace.join("\n")}"
            afr.update(successfully_read: false, json_failed: true, json_error_message: msg)
          end
        end
      end
    end
  end

  def load_single(afr)
    LOGGER.info "\n\n\n\n\nReading JSON for #{afr.avalon_id}\n\n\n\n\n\n"
    json_text = read_avalon_json(afr.json_url)
    @atom_feed_read = afr
    save_json(json_text)
    afr.update(successfully_read: true, json_failed: false, json_error_message: '')
  end

  private
  # reads the JSON record for a specific Avalon Item
  def read_avalon_json(url)
    # original code
    # uri = URI.parse(url)
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true
    # request = Net::HTTP::Get.new(uri)
    # request['Avalon-Api-Key'] = Rails.application.credentials[:avalon_token]
    # http.request(request).body

    # trying to set the read timeout
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Avalon-Api-Key'] = Rails.application.credentials[:avalon_token]
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) {|h|
      # MCO json service is slow in some instances so set the read timeout to 3 minutes
      h.read_timeout = READ_TIMEOUT_SECONDS
      h.request(request)
    }
    response.body

    # link = URI.parse(url)
    # request = Net::HTTP::Get.new(link.path)
    # begin
    #   response = Net::HTTP.start(link.host, link.port) {|http|
    #     # MCO json service is slow in some instances so set the read timeout to 3 minutes
    #     http.read_timeout = READ_TIMEOUT_SECONDS
    #     http.request(request)
    #   }
    #   response.body
    # rescue Net::ReadTimeout => e
    #   puts e.message
    # end
  end

  # parses the JSON response from read_avalon_json and determines if there are any errors, recording those or creating the
  # AvalonItem in RMD if not.
  def save_json(json_text)
    json = JSON.parse json_text
    if json["errors"]
      @atom_feed_read.update(successfully_read: false, json_failed: true, json_error_message: json["errors"])
    else
      write_avalon_item json, json_text
    end
  end

  # Does the heavy lifting of creating the AvalonItem in RMD
  def write_avalon_item(json, json_text)
    title = json["title"]
    collection = json["collection"]
    publication_date = json["publication_date"]
    summary = json["summary"]
    barcodes = json["fields"]["other_identifier"].select{|i| i.match(/4[0-9]{13}/) }
    unit = pod_metadata_unit(barcodes.first)
    avalon_item = AvalonItem.new(avalon_id: json["id"], title: title, collection: collection, json: json_text, pod_unit: unit, review_state: AvalonItem::REVIEW_STATE_DEFAULT)
    decision = PastAccessDecision.new(avalon_item: avalon_item, decision: AccessDeterminationHelper::DEFAULT_ACCESS, changed_by: 'automated ingest')
    decision.save!
    avalon_item.current_access_determination = decision
    avalon_item.save!
    barcodes.each do |bc|
      recording = Recording.new(
        mdpi_barcode: bc.to_i, title: title, description: summary, access_determination: Recording::DEFAULT_ACCESS,
        published: publication_date, fedora_item_id: json["id"], atom_feed_read_id: @atom_feed_read.id, unit: unit, avalon_item_id: avalon_item.id,
        copyright_end_date_text: '', date_of_first_publication_text: '', creation_date_text: ''
      )
      recording.save!
      perf = Performance.new(title: "Default Performance")
      perf.save!
      RecordingPerformance.new(performance_id: perf.id, recording_id: recording.id).save!
      Track.new(track_name: "Track 1", performance_id: perf.id).save!
    end
  end
end
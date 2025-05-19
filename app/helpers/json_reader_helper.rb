module JsonReaderHelper
  require 'nokogiri'
  require 'net/http'
  require 'uri'
  include AvalonItemsHelper

  LOGGER ||= Logger.new("#{Rails.root}/log/json_reader_helper.log", 10, 10.megabytes)
  READ_TIMEOUT_SECONDS = 180

  def read_json(scan_all = false)
    LOGGER.info "JsonReaderHelper#read_json - checking for unread JSON"
    # grab records that have not been successfully read AND have not failed due to a JSON read failure, or all records
    # with rescan == true, OR all records id scan_all == true.
    unread = scan_all ? AtomFeedRead.all : AtomFeedRead.where("(successfully_read = false AND json_failed = false) OR rescan = true")
    LOGGER.info "\t#{unread.size} new JSON records to read"
    puts "\t#{unread.size} new JSON records to read"
    AtomFeedRead.transaction do
      unread.each_with_index do |afr, i|
        begin
          LOGGER.info "\tReading #{i + 1} of #{unread.size} JSON records: #{afr.avalon_id}"
          puts "\tReading #{i + 1} of #{unread.size} JSON records: #{afr.avalon_id}"
          read_single(afr)
          puts "\t successfully read!"
        rescue => error
          if error.is_a? Net::ReadTimeout
            # In the event of a timeout, set the error message but leave the json_failed flag set to false. This will
            # identify any problematic records (the error message) but ALSO allow for subsequent re-attempts at
            # reading the record into RMD
            afr.update(successfully_read: false, json_failed: false, json_error_message: "The HTTP get request timed out after #{READ_TIMEOUT_SECONDS} seconds")
            LOGGER.error afr.json_error_message
            puts "\tTimed out!!!"
          else
            msg = "EXCEPTION: #{error.message}\n#{error.backtrace.join("\n")}"
            afr.update(successfully_read: false, json_failed: true, json_error_message: msg)
            LOGGER.error(msg)
            puts msg
          end
        end
      end
    end
  end

  private
  def read_single(afr)
    json_text = read_avalon_json(afr.json_url)
    @atom_feed_read = afr
    save_json(json_text)
    # un-flag anything that was a rescan by default
    now = DateTime.now
    afr.update(successfully_read: true, json_failed: false, json_error_message: '', rescan: false, json_last_parse_timestamp: now, avalon_last_updated: now)
    LOGGER.info("\tSuccessfully read JSON for #{afr.avalon_id}")
  end

  # parses the JSON response from read_single. If MCO reports an error message in the JSON object, the AFR is updated to
  # reflect this. If no JSON errors are present, the object is checked against RMD for creation/update
  def save_json(json_text)
    json = JSON.parse json_text
    if json["errors"]
      LOGGER.info("\tJSON record has errors #{@atom_feed_read.avalon_id}")
      @atom_feed_read.update(successfully_read: false, json_failed: true, json_error_message: "JSON: #{json[" errors "]}")
    else
      check_avalon_item json, json_text
    end
  end

  # Does the heavy lifting of creating/updating the AvalonItem in RMD. If the AvalonItem doesn't exist a new one will be created.
  # If the AvalonItem does exist, title changes in MCO will update the title of the AvalonItem but no other metadata
  # will be changed in the AvalonItem except for AvalonItem.json
  def check_avalon_item(json, json_text)
    title = json["title"]
    collection = json["collection"]
    publication_date = json["publication_date"]
    summary = json["summary"]
    barcodes = get_barcodes_from_json(json)

    # In the past items have appeared in the atom feed based on their query string which were NOT part of MDPI (they had 0
    # MDPI barcodes present in the other identifiers metadata). Check to ensure that at least one MDPI barcode is present
    # in the JSON and if not, raise an exception which will eventually be caught by #read_json and saved in the AFR object
    raise "NO MDPI BARCODES for #{json["id"]}" if barcodes.size == 0

    # determine the POD unit code or raise exception if it cannot be determined
    unit = pod_metadata_unit(barcodes.first)
    raise "Could not determine Unit: #{json["id"]}" if unit.blank?

    # look for existing first
    avalon_item = AvalonItem.where(avalon_id: json["id"]).first
    if avalon_item.nil?
      # new AvalonItem
      avalon_item = AvalonItem.new(
        avalon_id: json["id"], title: title, collection: collection,
        json: json_text, pod_unit: unit, review_state: AvalonItem::REVIEW_STATE_DEFAULT
      )
      decision = PastAccessDecision.new(
        avalon_item: avalon_item, decision: AccessDeterminationHelper::DEFAULT_ACCESS, changed_by: 'automated ingest'
      )
      decision.save!
      avalon_item.current_access_determination = decision
      barcodes.each do |bc|
        recording = Recording.new(
          mdpi_barcode: bc.to_i, title: title, description: summary, access_determination: Recording::DEFAULT_ACCESS,
          published: publication_date, fedora_item_id: json["id"], atom_feed_read_id: @atom_feed_read.id, unit: unit,
          avalon_item_id: avalon_item.id, copyright_end_date_text: '', date_of_first_publication_text: '',
          creation_date_text: ''
        )
        recording.save!
        perf = Performance.new(title: "Default Performance")
        perf.save!
        RecordingPerformance.new(performance_id: perf.id, recording_id: recording.id).save!
        Track.new(track_name: "Track 1", performance_id: perf.id).save!
      end
    else
      # existing avalon items whose AtomFeedRead is newer than the last read signify metadata edits or a publication
      # status change. RMD only alters existing AvalonItems to reflect TITLE changes in MCO and publication status
      # changes. All other metadata is ignored, but save the most recent copy of JSON to reflect title change in case
      # it changes
      avalon_item.title = title
      avalon_item.published_in_mco = json["published"]
      avalon_item.json = json_text
    end
    avalon_item.save!
  end

  def get_barcodes_from_json(json)
    barcodes = []
    json["fields"]["other_identifier_type"].each_with_index do |id, index|
      if id == "mdpi barcode"
        barcodes << json["fields"]["other_identifier"][index]
      end
    end
    barcodes
  end

  # reads the JSON record for a specific Avalon Item
  def read_avalon_json(url)
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
  end



end
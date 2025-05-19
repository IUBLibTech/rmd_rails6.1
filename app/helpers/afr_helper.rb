module AfrHelper
  require 'nokogiri'
  require 'net/http'
  require 'uri'

  LOGGER = Logger.new("#{Rails.root}/log/afr_helper.log", 10, 10.megabytes)
  POD_GROUP_KEY_SOLR_Q = '/GR[0-9]{8}/'
  # cap this at 1000 to prevent overloading MCO service
  ITEMS_PER_PAGE = 1000

  # responsible for reading from the atom feed to identify new records that need to be created in RMD
  # It works as follows:
  # 1) determines the timestamp of the last created AtomFeedRead record to know when the last read occurred.
  # 2) iterates through the feed (in newest to oldest order) examining the updated timestamp in the feed and compares
  # it to the timestamp determined in 1)
  # 3) when a timestamp of equal or older value is encountered, there is nothing new in the Atom Feed to read so the process halts
  # 4) for each timestamp that is newer than 1), it represents either a completely new record in MCO OR a record that has been
  # modified in MCO AFTER it was read in RMD. For the former, it creates a new AtomFeedRead object that will get picked
  # up by the JSON reader and subsequently created. For the later, it flags the RMD AvalonItem as modified_in_mco. A
  # subsequent load of the AvalonItem (avalon_item_controller#show) should be responsible for updating the JSON and removing the flag
  def read_atom_feed
    last_read = AtomFeedRead.order("avalon_last_updated DESC").first
    page = 1
    timestamp_reached = false
    more_pages = true
    read_records = 0
    LOGGER.info "Checking the Atom Feed for new content"
    AtomFeedRead.transaction do
      while more_pages && !timestamp_reached
        uri = gen_atom_feed_uri('desc', ITEMS_PER_PAGE, page)
        response = read_uri(uri)
        xml = parse_xml(response)
        total_records = xml.xpath('//totalResults')&.first.content.to_f # convert to a float so ceiling will work in division
        start_index = xml.xpath('//startIndex')&.first.content.to_i
        #puts xml.to_xhtml if total_records.nil? || start_index.nil?
        LOGGER.info "AfrHelper#read_atom_feed - reading page #{page} of #{(total_records / ITEMS_PER_PAGE).ceil}"
        if start_index < total_records
          xml.xpath('//entry').each do |e|
            LOGGER.info "Processing record #{read_records} of #{total_records.to_i}"
            title = e.xpath('title').first.content
            avalon_last_updated = DateTime.parse e.xpath('updated').first.content
            json_url = e.xpath('link/@href').first.value
            avalon_item_url = e.xpath('id').first.content
            avalon_id = avalon_item_url.chars[avalon_item_url.rindex('/') + 1..avalon_item_url.length].join("")
            read_records = read_records + 1
            # the very first read of the atom feed, last_read will be nil so read all pages
            if !last_read.nil? && avalon_last_updated <= last_read.avalon_last_updated
              timestamp_reached = true
              puts "Existing atom feed reads reached. Stopping the process."
              break
            else
              begin
                # check if this is an existing record that has been altered in MCO since the last read. The alteration
                # may be the result of being published in MCO
                if AtomFeedRead.where(avalon_id: avalon_id).exists?
                  LOGGER.info ("Existing record found in atom feed: #{avalon_id} - updating")
                  AtomFeedRead.where(avalon_id: avalon_id).first.update(rescan: true, atom_feed_update_timestamp: DateTime.now)
                  AvalonItem.where(avalon_id: avalon_id).first.update(modified_in_mco: true)
                else
                  puts("New record found in atom feed: #{avalon_id} - creating")
                  AtomFeedRead.new(
                    title: title, avalon_last_updated: avalon_last_updated, json_url: json_url,
                    avalon_item_url: avalon_item_url, avalon_id: avalon_id, entry_xml: e.to_s, atom_feed_new_timestamp: DateTime.now
                  ).save
                end
              rescue Exception => e
                LOGGER.error e.message
                LOGGER.error e.backtrace.join("\n")
              end
            end
          end
          more_pages = (start_index + ITEMS_PER_PAGE) < total_records
          page += 1
        end
      end
    end
  end



  # FIXME: this should be in JsonReaderHelper???
  # reads the current JSON for the specified AvalonItem and saves it in AvalonItem.json - returns true if the read was
  # successful, otherwise false
  def read_json(avalon_item)
    begin
      uri = URI.parse avalon_item.atom_feed_read.json_url
      something = read_uri(uri)
      if something.kind_of? Net::HTTPSuccess
        json_text = something.body
        avalon_item.json = json_text
        avalon_item.save!
        return true
      else
        LOGGER.warn "MCO JSON request returned #{something} for #{uri}"
        avalon_item.atom_feed_read.update(json_failed: true, json_error_message: "MCO JSON request returned #{something} for #{uri}")
        return false
      end
    rescue Exception => e
      msg = ""
      msg << e.message
      msg << e.backtrace.join("\n")
      puts msg
      LOGGER.warn msg
      avalon_item.atom_feed_read.update(json_failed: true, json_error_message: msg)
      false
    end
  end

  def fix_atom_feed
    page = 1
    more_pages = true
    missing = 0
    while more_pages
      uri = gen_atom_feed_uri('desc', ITEMS_PER_PAGE, page)
      response = read_uri(uri)
      xml = parse_xml(response)
      total_records = xml.xpath('//totalResults')&.first.content.to_f # convert to a float so ceiling will work in division
      start_index = xml.xpath('//startIndex')&.first.content.to_i
      if start_index < total_records
        xml.xpath('//entry').each do |e|
          title = e.xpath('title').first.content
          avalon_last_updated = DateTime.parse e.xpath('updated').first.content
          json_url = e.xpath('link/@href').first.value
          avalon_item_url = e.xpath('id').first.content
          avalon_id = avalon_item_url.chars[avalon_item_url.rindex('/') + 1..avalon_item_url.length].join("")
          begin
            # check if this is an existing record that has been altered in MCO since the last read
            if AtomFeedRead.where(avalon_id: avalon_id).exists?
              # do nothing, the record has already been ingested
              # puts("\tExisting record found for #{avalon_id} - skipping")
            else
              puts("NEW record found!!! #{avalon_id} - creating AtomFeedRead")
              AtomFeedRead.new(
                title: title, avalon_last_updated: avalon_last_updated, json_url: json_url,
                avalon_item_url: avalon_item_url, avalon_id: avalon_id, entry_xml: e.to_s, atom_feed_new_timestamp: DateTime.now
              ).save
              missing += 1
              puts "Found #{missing} #{'record'.pluralize(missing)} so far."
            end
          rescue Exception => e
            LOGGER.error e.message
            LOGGER.error e.backtrace.join("\n")
          end
          more_pages = (start_index + ITEMS_PER_PAGE) < total_records
        end
        page += 1
      end
    end
  end

  # generates a "default" atom feed read uri: desc order, 100 items per page, and starting with page 1
  def gafu
    gen_atom_feed_uri('desc', ITEMS_PER_PAGE, 1)
  end

  def test_atom_sort_order
    page = 1
    more_pages = true
    last_timestamp = nil
    read_records = 0
    while more_pages
      uri = gen_atom_feed_uri('desc', ITEMS_PER_PAGE, page)
      response = read_uri(uri)
      xml = parse_xml(response)
      total_records = xml.xpath('//totalResults')&.first.content.to_f # convert to a float so ceiling will work in division
      start_index = xml.xpath('//startIndex')&.first.content.to_i
      if start_index < total_records
        puts "\tProcessing record #{read_records} of #{total_records.to_i}"
        xml.xpath('//entry').each do |e|
          ts = DateTime.parse e.xpath('updated').first.content
          if last_timestamp.nil?
            last_timestamp = ts if last_timestamp.nil?
          else
            puts "#{ts} older than #{last_timestamp} = #{ts <= last_timestamp}"
            if ts <= last_timestamp
              last_timestamp = ts
            else
              raise "Atom Feed out of order!!!"
            end
          end
          read_records = read_records + 1
          more_pages = (start_index + ITEMS_PER_PAGE) < total_records
        end
        page += 1
      end
    end
  end

  # Reads the atom feed, parsing <entry> elements to determine if there is new/updated content in MCO.
  #
  # Method params exist to deal with 3 use cases:
  #  * Typical use is reading from the atom feed in descending timestamp order to ONLY parse those records which are new
  #    or have been updated since the last time the AFR was read. Once a matching updated timestamp is reached, RMD stops
  #    parsing the atom feed because the remaining items *should* match what is in RMD. DEFAULT read_all and updated_existing
  #    values for this use case.
  #  * De-sync use case: RMD and the atom feed have become out of sync. The atom feed contains new/updated AFRs which
  #    RMD is unable to discover because they have timestamps older than what RMD determines to be "last_read". 11/1/23
  #    it was discovered that RMD was missing more than 13K AFRs being reported in the atom feed but having older timestamps
  #    than the last time the AFR was parsed. When this happens the following attributes can be used to read everything
  #    and selectively process only new, or process new AND existing ARF objects
  #       * read_all == true updated_existing == true: we're basically re-parsing EVERYTHING in RMD. VERY expensive
  #         time wise and should be avoided. See if the Avalon Team can generate dump file if this is needed
  #       * read_all == true update_existing == false: we're only interested in finding MISSING AFRs. Existing records are
  #         completely ignore.
  #       * read_all == false update_existing == whatever: doesn't matter what update_existing is set to, read_all false
  #         will break at timestamp boundary
  def read_atom_feed2(read_all = false, update_existing = false)
    @updating = 0
    @new = 0
    @total = 0
    page = 1

    more_pages = true
    total_records = nil

    AtomFeedRead.transaction do
      stop_timestamp = read_all ? nil : AtomFeedRead.stop_timestamp
      LOGGER.info "Reading AFR page: #{page}"
      while more_pages
        LOGGER.info "Page #{page} of #{total_records.blank? ? 'calculating' : "#{(total_records.to_f / ITEMS_PER_PAGE).ceil}"}"
        xml = read_afr_page(page)
        total_records = total_items(xml) if total_records.nil?
        entries = xml.xpath('//entry')
        entries.each do |entry|
          @total += 1
          stop = parse_entry(entry, stop_timestamp, update_existing)
          # parse_entry returns whether parsing should stop but is only relevant if read_all == false, only
          # return from the read if we are NOT reading all AND we've hit the stop timestamp in the atom feed
          return if !read_all && stop
        end
        more_pages = entries.size > 0
        page += 1
      end
      LOGGER.info "\n\n########################"
      LOGGER.info "Atom feed read complete!"
      LOGGER.info "#{@updating} records need rescanning"
      LOGGER.info "#{@new} new records created"
      puts "#{@total} records found in Atom Feed"
    end
  end

  # reads the specified page from the atom feed read in 'desc' timestamp order, with ITEMS_PER_PAGE items
  def read_afr_page(page)
    uri = gen_atom_feed_uri('desc', ITEMS_PER_PAGE, page)
    response = read_uri(uri)
    parse_xml(response)
  end

  private
  # parses an xml <entry>. As a side effect, will create any new atom feed objects not already in RMD, and optionally
  # update any atom feed entries which have a newer timestamp than what is stored in the database, also setting rescan
  # to true.
  #
  # Returns whether the atom feed read should stop if an existing timestamp is encountered: if stop timestamp
  # is set and is NEWER that this entry, it will return true, otherwise (or if stop_timestamp is nil) it returns false.
  #
  # NOTE: stop_timestamp SHOULD typically be set with the timestamp from the most recently read
  # AtomFeedRead.atom_feed_update_timestamp value when reading the atom feed needs to cease once previously read records
  # are encountered
  def parse_entry(xml, stop_timestamp = nil, update_existing = false)
    avalon_item_url = xml.xpath('id').first.content
    avalon_id = avalon_item_url.split('/').last
    existing = AtomFeedRead.where(avalon_id: avalon_id).first
    if existing
      # check whether we're stopping and if yes, is the current entry is older than the stop timestamp?
      entry_last_updated = DateTime.parse(xml.xpath('updated').first.content)
      stopping = !stop_timestamp.nil? && (stop_timestamp > entry_last_updated)
      if update_existing && !stopping
        # does this record need a rescan?
        rescan = entry_last_updated != existing.last_read
        @updating += 1 if rescan
        puts "\tRescan (#{avalon_id}): last_read #{ short_ts existing.last_read} | updated #{ short_ts entry_last_updated}" if rescan
        existing.update(rescan: rescan, atom_feed_update_timestamp: entry_last_updated)
      end
      stopping
    else
      # create a new AFR object
      title = xml.xpath('title').first.content
      entry_last_updated = DateTime.parse xml.xpath('updated').first.content
      json_url = xml.xpath('link/@href').first.value
      AtomFeedRead.new(
        title: title, avalon_last_updated: entry_last_updated, json_url: json_url,
        avalon_item_url: avalon_item_url, avalon_id: avalon_id, entry_xml: xml.to_s
      ).save!
      puts "\tNew AFR found: #{short_ts entry_last_updated}"
      @new += 1
      # always continue after finding a new record
      false
    end
  end

  def total_items(xml)
    xml.xpath('//totalResults')&.first.content.to_f # convert to a float so ceiling will work in division
  end

  def start_index(xml)
    xml.xpath('//startIndex')&.first.content.to_f
  end

  # in the past, the atom feed read has not honored ITEMS_PER_PAGE if is was beyonf 100 items, so use this to read the
  # value the FEED reports to calculate whether we are on the last page of items.
  def items_per_page(xml)
    xml.xpath('//itemsPerPage')&.first.content.to_f
  end

  # converts an HTTP response body into a Nokogir::XML object with namespaces removed
  def parse_xml(response)
    @xml =  @xml = Nokogiri::XML(response.body).remove_namespaces!
  end

  # makes a HTTPS request at the specified URI and returns the response
  def read_uri(uri)
    puts "Making MCO service request: #{uri.to_s}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Avalon-Api-Key'] = Rails.application.credentials[:avalon_token]
    http.request(request)
  end

  def short_ts(timestamp)
    timestamp.strftime("%F %T")
  end

  # responsible for generating the URI to read multiple records from the atom feed
  def gen_atom_feed_uri(order, rows, page, identifier = POD_GROUP_KEY_SOLR_Q)
    URI.parse(Rails.application.credentials[:avalon_url].gsub('<identifier>', identifier).gsub('<order>', order).gsub('<row_count>', rows.to_s).gsub('<page_count>', page.to_s))
  end

  # responsible for generating the URI to read a SINGLE Avalon Items atom feed record
  def gen_atom_feed_uri_for(avalon_id)
    URI.parse(Rails.application.credentials[:avalon_url].gsub('other_identifier_sim:<identifier>&sort=timestamp+<order>&rows=<row_count>&page=<page_count>', "id:#{avalon_id}"))
  end
end

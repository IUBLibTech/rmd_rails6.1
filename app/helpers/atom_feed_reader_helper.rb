module AtomFeedReaderHelper
  require 'nokogiri'
  require 'net/http'
  require 'uri'



  # grabs the oldest 100 Avalon Items from the RSS feed and creates AtomFeedRecords
  # def self.prepopulate
  #   if AtomFeedRead.all.size == 0
  #     response  = read('asc', 100, 1)
  #     atom_feed_reads = generate_afr(response)
  #     AtomFeedRead.transaction do
  #       atom_feed_reads.each(&:save!)
  #     end
  #   end
  # end


  # def self.read_current
  #   last_read = AtomFeedRead.all.order("avalon_last_updated DESC").first
  #   page = 1
  #   keep_reading = true
  #   count = 0
  #   AtomFeedRead.transaction do
  #     while keep_reading do
  #       response = read('desc', 1000, page)
  #       total_records =
  #       atom_feed_reads = generate_afr(response)
  #       break if atom_feed_reads.size == 0
  #       atom_feed_reads.each do |a|
  #         if a.avalon_last_updated <= last_read.avalon_last_updated || a.avalon_id == last_read.avalon_id
  #           keep_reading = false
  #           break
  #         end
  #         a.save!
  #         count += 1
  #       end
  #       page += 1
  #     end
  #   end
  # end


  # Reads a SINGLE atom feed item
  # def self.read_atom_record(identifier)
  #   response = read('desc', 100, 1, identifier)
  #   atom_feed_reads = generate_afr(response)
  #   # FIXME: this should be an error and logged so that data can be corrected in MCO
  #   raise "Avalon should only have a single <entry> for the identifier: #{identifier}" if atom_feed_reads.size > 1
  #   atom_feed_reads[0]
  # end

  # # returns the raw response body JSON text
  # def self.read_avalon_json(url)
  #   uri = URI.parse(url)
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   http.use_ssl = true
  #   request = Net::HTTP::Get.new(uri)
  #   request['Avalon-Api-Key'] = Rails.application.credentials[:avalon_token]
  #   http.request(request).body
  # end

  def parse_json(json)
    title = json["title"]
    mcs = json["main_contributors"]
    atom_feed_read_id = json["id"]
    publication_date = json["publication_date"]
    published = json["published"]
    description = json["summary"]
  end

  def self.gen_prepop_url
    URI.parse(Rails.application.credentials``[:avalon_url].gsub('<identifier>', AtomFeedReaderTask::POD_GROUP_KEY_SOLR_Q).gsub('<order>', 'asc').gsub('<row_count>', "100").gsub('<page_count>', "1"))
  end

  def self.single_record_url(avalon_id)
    URI.parse(Rails.application.credentials[:avalon_url].gsub('<identifier>', avalon_id).gsub('<order>', 'asc').gsub('<row_count>', "100").gsub('<page_count>', "1"))
  end

  private
  def self.generate_afr(response)
    atom_feed_reads = []
    @xml =  @xml = Nokogiri::XML(response.body).remove_namespaces!
    @xml.xpath('//entry').each do |e|
      title = e.xpath('title').first.content
      avalon_last_updated = DateTime.parse e.xpath('updated').first.content
      json_url = e.xpath('link/@href').first.value
      avalon_item_url = e.xpath('id').first.content
      avalon_id = avalon_item_url.chars[avalon_item_url.rindex('/') + 1..avalon_item_url.length].join("")
      atom_feed_reads << AtomFeedRead.new(title: title, avalon_last_updated: avalon_last_updated, json_url: json_url, avalon_item_url: avalon_item_url, avalon_id: avalon_id)
    end
    atom_feed_reads
  end
  def self.parse_xml(response)
    @xml =  @xml = Nokogiri::XML(response.body).remove_namespaces!
  end

  def self.read(order, rows, page, identifier = AtomFeedReaderTask::POD_GROUP_KEY_SOLR_Q)
    uri = URI.parse(Rails.application.credentials[:avalon_url].gsub('<identifier>', identifier).gsub('<order>', order).gsub('<row_count>', rows.to_s).gsub('<page_count>', page.to_s))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Avalon-Api-Key'] = Rails.application.credentials[:avalon_token]
    http.request(request)
  end

  def self.updated_in_mco?(avalon_id)
    uri = AtomFeedReaderHelper.single_record_url(avalon_id)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Avalon-Api-Key'] = Rails.application.credentials[:avalon_token]
    xml = parse_xml( http.request(request) )
    ts = DateTime.parse(xml.xpath('//updated').first.content)
    afr = AtomFeedRead.where(avalon_id: avalon_id).first
    # puts "Comparing original: #{afr.created_at} to updated_at: #{ts}"
    afr.created_at != ts
  end

end

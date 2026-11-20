module McoDumpReaderHelper
  include AfrHelper
  require 'nokogiri'



  def re_sync
    file = Dir["#{Rails.root}/tmp/mco_sync/*.json"].first
    begin
      delete_afrs = parse_file(file)
      delete_afrs.each do |afr|
        double_check(afr.avalon_id)
      end
      #FileUtils.mv(file, "#{file}.old")
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
    end
  end

  def parse_file(file)
    timestamp = DateTime.parse file.split("/").last.split(".")[1].gsub("_", ":")
    @not_in_rmd = [] # items appear in the MCO dump which do not appear in RMD. What to do with these???
    @updated_in_rmd = [] # items which should be updated in RMD (title change or publication status change)
    @ids_in_mco = [] # the avalon ids present in the dump file
    real_deletes = [] # items which should be deleted in RMD
    # items which appear in RMD but DO NOT appear in the dump file, but which have a newer timestamp than the dump file.
    # These are items which were ingested into RMD between the time the dump was generated (file timestamp) and when this
    # re-sync was run
    too_new_deletes = []

    json = JSON.parse(File.read(file))
    # step 1) look up avalon id to compare with RMD - updating title and published status if necessary.
    # Flag everything in MCO which is NOT IN RMD
    json.each_with_index do |j, index|
      puts "#{index + 1} of #{json.size} JSON Entries"
      aid = j["id"]
      @ids_in_mco << aid
      title = j["title"]
      published = j["published"]

      ai = AvalonItem.where(avalon_id: aid).first
      if ai
        # compare if title or published status has changed
        # ai.update(title: title, published_in_mco: published) if ai.title != title || ai.published_in_mco != published
        @updated_in_rmd << ai if ai.title != title || ai.published_in_mco != published
      else
        @not_in_rmd << j
      end
    end

    # step 2) identify records in RMD which did not appear in MCO json dump
    # include :avalon_last_updated as originally atom_feed_update_timestamp was not used
    ids_in_rmd = AtomFeedRead.all.pluck(:avalon_id, :atom_feed_update_timestamp, :avalon_last_updated)
    ids = ids_in_rmd.collect{|afr| afr[0]}.flatten

    # what appears in RMD but IS NOT in the MCO dump. These are *potential* deletions: now check the timestamps of the
    # AtomFeedRead of each of these to see if it's NEWER than the timestamp derived from the dump file
    subtract = ids - @ids_in_mco
    subtract.each_with_index do |sub, index|
      puts "#{index + 1} of #{subtract.size} Possible Deletions Being Verified"
      afr = AtomFeedRead.where(avalon_id: sub).first
      ts = afr.atom_feed_update_timestamp.nil? ? afr.avalon_last_updated : afr.atom_feed_update_timestamp
      if ts > timestamp
        puts "\tToo new - Dump Timestamp: #{timestamp.strftime("%F %T")} | AFR Timestamp: #{ts.strftime("%F %T")}"
        too_new_deletes << afr
      else
        puts "DELETE IT! - #{afr.avalon_id}"
        real_deletes << afr
      end
    end
    puts "Too new: #{too_new_deletes.size}"
    puts "Real Deletes: #{real_deletes.size}"
    real_deletes
  end

  # this method takes a paranoid stance and rechecks the atom feed for the specifc Avalon ID. If it does not appear in the
  # Atom Feed, the item can safely be deleted.
  def double_check(aid)
    url = "https://media.dlib.indiana.edu/catalog.atom?q=id:<aid>&rows=1&page=1"
    url = URI.parse(url.gsub('<aid>', aid))
    xml = read_uri(url)
    xml = Nokogiri::XML(xml.body).remove_namespaces!
    total_records = xml.xpath('//totalResults')&.first.content.to_f
    raise "This should not happen..." if total_records != 0
    AtomFeedRead.where(avalon_id: aid).delete_all
    AvalonItem.where(avalon_id: aid).delete_all


  end


end

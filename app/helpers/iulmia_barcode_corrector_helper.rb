# This module was created to correct AvalonItems belonging to IULMIA that were incorrectly parsed from MCO JSON.
# It should NOT be used for any production-related work other than correcting those errors.
#
# Background: Filmdb (IULMIA's inventory system) was included as a bibliographic import source for MCO. With an MDPI barcode,
# MCO can retrieve the MODS for a given recording from Filmdb. Since the MODS source for the record is included as part
# of the JSON, json["fields"]["other_identifier_types"] added a "filmdb" identifier type, as well as
# json["fields"]["other_identifier"] including the single MDPI barcode used to look up the MODS.
#
# Originally, with collab with MCO team, it was decided that using MDPI barcode pattern matching in
# json["fields"]["other_identifier"] was sufficient for determining each digital file (an RMD Recording) that comprised
# an AvalonItem. Since the advent of Filmdb as a MODS source, and the "filmdb" other identifier type, this results in
# *duplicated* MDPI barcodes in that list, which, when parsed with pattern matching alone, creates extra Recordings in RMD.
#
# This module attempts to correctly delete those "extras"
#
# Caveats:
# Simply checking for a duplicated MDPI barcode in AvalonItem.recordings is not sufficient as there are *correct* use
# cases where a barcode SHOULD appear more than one: source recordings (physical media) that have multiple "sides" result
# one digital file for each "side" (2 Recordings with the same barcode). Additionally, there were use cases where it
# was necessary to create multiple files from a single side - video tapes with multiple playback speed for instance.
#
# Also, some items for IULMIA did not use Filmdb MODS for the bib import, they used IUCat. These records will not suffer
# from this duplication error.
#
# The only reliable way to identify errors is to reprocess the JSON (omitting the Filmdb identifier if present) and
# comparing that to the Recordings that exist for that AvalonItem.
#
# The last concern is how to deal with AvalonItems that IULMIA staff have modified in RMD. Whenever it is clear nothing
# has changed in the record it is safe to delete. For records that do have modifications: waiting to hear back from
# IULMIA on how to process those.
#
module IulmiaBarcodeCorrectorHelper
  include JsonReaderHelper
  FIXED = []
  NOT_FIXED = []
  BC_MATCH = []

  def fixit
    ais = AvalonItem.where(pod_unit: "B-IULMIA").includes(recordings: [performances: :tracks])
    puts "Found #{ais.size} IULMIA items"
    ais.each_with_index do |ai, i|
      puts "\n\n#{i + 1} of #{ais.size}"
      if barcodes_match?(ai)
        puts "Not Necessary: #{ai.id}!"
        BC_MATCH << ai
      else
        # the MDPI barcodes that SHOULD be in the AvalonItem, this DOES NOT include the erroneous Filmdb MDPI barcodes
        json = JSON.parse(ai.json)
        json_bcs = get_barcodes_from_json(json)

        # the bad barcodes appearing as filmdb identifiers in the JSON that SHOULD NOT be duplicated
        bad = get_filmdb_barcodes_from_json(json)

        # the barcodes that are ACTUALLY in the AvalonItem, this MAY OR MAY NOT include duplicates of the Filmdb barcodes
        # NOTE: "may or may not" because I've encountered instances where Filmdb barcodes are present in the JSON but
        # there are no duplicates - probably because a user manually deleted the duplicated recording(s).
        ai_bcs = ai.recordings.collect{|r| r.mdpi_barcode.to_s }

        if bad.size == 0
          puts "No Bad Barcodes"
          BC_MATCH << ai unless BC_MATCH.include? ai
        else
          puts "#{bad} 'filmdb' barcodes"
          Recording.transaction do
            # iterate through each bad Filmdb barcode and compare it to whats in the AvalonItem
            bad.each do |b|
              # how many times the barcode SHOULD appear in the AvlonItem
              j_count = json_bcs.count(b)
              # how many times the barcode DOES appear in the AvalonItem
              a_count = ai_bcs.count(b)
              # if a_count is >= 1 than j_count, there are instances where a Filmdb MDPI barcode was duplicated into a Recording
              if (a_count - j_count >= 1)
                candidates = delete_candidates(ai, b)
                if candidates.size >= 1
                  # delete a single instance of the barcode, further iterations should catch the same barcode if repeated more than once
                  remove_candidate(candidates[0])
                  FIXED << ai unless FIXED.include?(ai)
                else
                  NOT_FIXED << ai unless NOT_FIXED.include?(ai)
                end
              elsif a_count - j_count < 0
                NOT_FIXED << ai unless NOT_FIXED.include?(ai)
              end
            end
          end
        end
      end
    end
    puts "\n\n\nResults\n************************"
    puts "\tFixed: #{FIXED.size}"
    puts "\tUnfixable: #{NOT_FIXED.size}"
    puts "\tBarcodes Match: #{BC_MATCH.size}"
    puts "\tTotal: #{ais.size}, Processed: #{FIXED.size + BC_MATCH.size + NOT_FIXED.size}"
  end

  # checks to see if the MDPI barcodes in the JSON match the collected Recording barcodes in the AvalonItem. A match
  # means that exactly the same barcodes, and count of each are present.
  def barcodes_match?(avalon_item)
    air = avalon_item.recordings.collect{|r| r.mdpi_barcode.to_s}.sort
    aibcs = get_barcodes_from_json(JSON.parse(avalon_item.json)).sort
    air == aibcs
  end

  def get_filmdb_barcodes_from_json(json)
    bcs = []
    json["fields"]["other_identifier_type"].each_with_index do |id, index|
      if id == "filmdb"
        # filmdb identifiers can ALSO BE IUCat barcodes (beginning with a 3 instead of a 4), these barcodes were not
        # problematic in the original JSON parser as it only looked for MDPI barcodes (ones that begin with a 4)
        bc = json["fields"]["other_identifier"][index]
        bcs << bc if  ApplicationHelper.valid_barcode?(bc.to_i)
      end
    end
    bcs
  end

  def delete_candidates(avalon_item, mdpi_barcode)
    avalon_item.recordings.select do |r|
      r.mdpi_barcode.to_s == mdpi_barcode and r.created_at == r.updated_at and
        r.performances.size == 1 and r.performances[0].created_at == r.performances[0].updated_at and
        r.performances[0].tracks.size == 1 and r.performances[0].tracks[0].created_at == r.performances[0].tracks[0].updated_at and
        r.performances[0].tracks[0].people.size == 0 and r.performances[0].tracks[0].works.size == 0
    end
  end

  def remove_candidate(recording)
    Recording.transaction do
      tracks = recording.performances.collect{|p| p.tracks }.flatten
      p_notes = recording.performances.collect{|p| p.performance_notes }
      tracks.each do |t|
        t.delete
      end
      p_notes.each do |note|
        note.delete
      end
      recording.performances.each do |p|
        p.delete
      end
      recording.recording_performances.each do |rp|
        rp.delete
      end
      recording.delete
    end
  end

end

# This module handles ingesting IULMIA access determinations made by the copyright librarian prior to the existence of RMD.
# It ingests the "matches.csv" spreadsheet from JIRA issue IUFD-1144. Parsing logic is as follow:
#
# 1) Iterate through each row
# 2) Check if item belongs to IULMIA - only IULMIA access determinations are being ingested but the spreadsheet contains
#    metadata for other campus units (B-KINSEY)
# 3) Check if an MDPI barcode is present. The spreadsheet contains main items that were NOT digitized through MDPI so will
#    not have a corresponding item in RMD. Add these to "FAILED" spreadsheet
# 4) If MDPI barcode is present do one of the following
#    a) if the MDPI barcode belongs to an AvalonItem comprised of ONLY that MDPI barcode (AvalonItem with 1 Recording),
#       set access and move on
#    b) If the MDPI barcode belongs to ONLY 1 AvalonItem but the AvalonItem is comprised of multiple MDPI barcodes
#       (AvalonItem with >1 Recordings), store the row in the BC_MAP with the barcode as the key, and appeand the AvalonItem
#       to FOUND_AVALON_ITEMS. The later will be processed later
#    c) If the MDPI barcode belongs to MORE THAN 1 AvalonItem, fail the ingest as it will be unclear which AvalonItem the
#       barcode applies to.
#    d) IF the MDPI barcode is not present, fail the row.
# 5) Once row parsing for the spreadsheet is complete, process any AvalonItems stored in FOUND_AVALON_ITEMS
#    a) Compare each AvalonItem's Recordings to those stored in the BC_MAP.
#    b) If all MDPI barcodes are present in the map, compare all "In Copyright" column values for those Recordings
#       i) If they are all identical, set access
#       ii) If they are not all identical, fail
#    c) If all AvalonItem Recordings are not accounted for in the BC_MAP, fail all rows in BC_MAP that ARE present
#
#
module IulmiaAccessDeterminationHelper
  require 'csv'

  DEFAULT_LOCATION = "#{Rails.root}/tmp/adss/matches.csv"
  IULMIA_UNIT_NAME = "B-IULMIA"

  UNIT = "UNIT"
  MDPI_BC = "MDPI_BC"
  IN_COPYRIGHT = "IN_COPYRIGHT"
  COPYRIGHT_EXP = "COPYRIGHT_EXP"
  HEADER_INDICES = {
    UNIT => 0, MDPI_BC => 3, IN_COPYRIGHT => 12, COPYRIGHT_EXP => 13
  }
  # maps MDPI barcodes to their row data
  BC_MAP = {}
  FOUND_AVALON_ITEMS = {}

  # Final arrays containing output for files. The sum of these should equal the size of the original spreadsheet
  NOT_IULMIA = []
  NOT_IN_RMD = []
  FAILED = []
  PASSED = []

  # temp array used while processing rows in spreadsheet
  FOUND = []

  # temp map, after all parsing should contain AvalonItems as keys which map to their corresponding rows in the
  # spreadsheet where all rows are present
  GOOD = {}

  # After parse_rows -> process_found, contains AvalonItems mapped to arrays of spreadsheet rows. Post process this list to
  # determine if everything for each AvalonItem is present in the spreadsheet
  POSSIBLE = {}


  @@HEADER
  @@DIR_NAME = "#{Rails.root}/tmp/adss/"

  def self.do_it
    parse_rows
    puts "#{FOUND.size + NOT_IN_RMD.size + NOT_IULMIA.size} of #{@@ROW_COUNT} rows were identified"
    process_found
    puts "#{NOT_IULMIA.size + NOT_IN_RMD.size + FAILED.size + GOOD.collect{|k, v| v.nil? ? 0 : v.size }.inject(:+) + POSSIBLE.collect{|k,v| v.size}.inject(:+)} of #{@@ROW_COUNT}"
    process_possible
    puts "#{NOT_IULMIA.size + NOT_IN_RMD.size + FAILED.size + GOOD.collect{|k, v| v.nil? ? 0 : v.size }.inject(:+) } of #{@@ROW_COUNT}"
    process_good
    write_to_files
    puts "Are we good? Processed: #{NOT_IULMIA.size + NOT_IN_RMD.size + FAILED.size + PASSED.size} of total rows: #{@@ROW_COUNT}"
    puts "\tNot IULMIA: #{NOT_IULMIA.size}"
    puts "\tNot in RMD: #{NOT_IN_RMD.size}"
    puts "\t\tWITH MDPI Barcode: #{NOT_IN_RMD.select{|r| !r[HEADER_INDICES[MDPI_BC]].blank? }.size}"
    puts "\tFAILED: #{FAILED.size}"
    puts "\tPassed: #{PASSED.size}"
    nil
  end

  # iterates through the spreadsheet and looks at each row, splitting items into the following arrays:
  # NOT_IULMIA contains any of the Kinsey content or anything not belonging to B-IULMIA
  # MOT_IN_RMD contains any item belongint to IULMIA but not having an MDPI Barcode, OR, having an MDPI Barcode in the
  # spreadsheet but not mapping to anything in RMD
  def self.parse_rows(file_path=DEFAULT_LOCATION)
    rows = CSV.read(file_path)
    @@HEADER = rows[0]
    @@ROW_COUNT = rows.size - 1
    puts "Parsing Rows"
    rows.each_with_index do |row, index|
      next if index == 0
      puts "\tProcessing row #{index} of #{rows.size - 1}"
      puts "#{row}" if index > 46916
      row = rows[index]
      if (iulmia?(row[HEADER_INDICES[UNIT]]))
        bc = row[HEADER_INDICES[MDPI_BC]]
        if (bc.blank?)
          row << "FAILED: no MDPI barcode in spreadsheet. Likely not digitized."
          NOT_IN_RMD << row
        else
          if Recording.where(mdpi_barcode: bc).size > 0
            FOUND << row
            BC_MAP[bc] = [] if BC_MAP[bc].nil?
            BC_MAP[bc] << row
          else
            row << "FAILED: MDPI barcode does not appear in RMD. Still in Dark Avalon?"
            NOT_IN_RMD << row
          end
        end
      else
        row << "FAILED: Not B-IULMIA content"
        NOT_IULMIA << row
      end
    end

  end

  # run AFTER parse_rows - this method looks through FOUND (generated by parse_rows) and further filters into:
  # FAILED: if the row barcode is determined to belong to MORE THAN ONE AvalonItem
  # GOOD: if the row barcode belongs to a single AvalonItem that has only this barcode as a child
  # POSSIBLE: if the row barcode belongs to a single AvalonItem but the AvalonItem has more than one Recording barcode
  def self.process_found
    puts "Processing Found"
    FOUND.each_with_index do |row, i|
      puts "\tprocessing found: #{i + 1} of #{FOUND.size}"
      recordings = Recording.where(mdpi_barcode: row[HEADER_INDICES[MDPI_BC]])
      # barcode appears once in RMD
      if recordings.size == 1
        ai = recordings.first.avalon_item
        if ai.recordings.size == 1
          if GOOD[ai].nil?
            # this row represents the whole AvalonItem
            GOOD[ai] = [row]
          else
            # this barcode belonging to a single AvalonItem was duplicated in the spreadsheet
            row << "FAILED: row appears multiple times in spreadsheet but only single digital file"
            FAILED << row
            # if the row is still in the Hash, move it to FAILED and replace with nil so that future matches will still fail
            unless GOOD[ai].nil?
              row << "FAILED: row appears multiple times in spreadsheet but only single digital file in RMD"
              FAILED << row
              GOOD[ai] = nil
            end
          end
        else
          # append and continue iterating through to see if everything belonging to the AvalonItem is present
          POSSIBLE[ai] = [] if POSSIBLE[ai].nil?
          POSSIBLE[ai] << row
        end
      else
        # two possibilities
        # a) the original SOURCE recording was digitized to more than one file but still belongs to a single AvalonItem, or
        # b) the digital file appears in more than one AvalonItem (a FAIL case)
        ais = recordings.collect{|r| r.avalon_item }.uniq
        if ais.size == 1
          # this is a) above
          # append and continue iterating through to see if everything belonging to the AvalonItem is present
          POSSIBLE[ais.first] = [] if POSSIBLE[ais.first].nil?
          POSSIBLE[ais.first] << row
        else
          # FAIL
          row << "FAILED: appears in more than 1 AvalonItem"
          FAILED << row
        end
      end
    end
  end

  # Run AFTER process_found - this method looks through POSSIBLE filtering based on whether each discovered AvalonItem
  # has all of its child Recording barcodes present in the spreadsheet:
  # All present: moves the AvalonItem to GOOD
  # Not all present: FAILS the rows
  def self.process_possible
    puts "Processing Possible"
    POSSIBLE.each_with_index do |pair, i |
      ai = pair[0]
      rows = pair[1]
      puts "\tProcessing possible: #{ai.id}: #{i + 1} of #{POSSIBLE.size}"
      recording_bcs = ai.recordings.collect{|r| r.mdpi_barcode.to_s }
      ss_bcs = rows.collect{|row| row[HEADER_INDICES[MDPI_BC]] }
      if recording_bcs.sort == ss_bcs.sort
        GOOD[ai] = rows
      else
        rows.each do |row|
          row << "FAILED: Barcode mismatch between RMD and Spreadsheet"
          FAILED << row
        end
      end
    end
  end

  # run last - this iterates through GOOD after all parsing/processing is complete. It compares "Copyright Expiration"
  # and "In Copyright" statuses to determine if they all match and what status should be assigned to the AvalonItem
  def self.process_good
    puts "Processing GOOD"
    GOOD.keys.each_with_index do |ai, i|
      puts "\tprocess good: #{ai.id}: #{i + 1} of #{GOOD.keys.size}"
      next if GOOD[ai].nil?
      in_cp_vals = GOOD[ai].collect{|row| row[HEADER_INDICES[IN_COPYRIGHT]] }.uniq
      cp_exp_vals = GOOD[ai].collect{|row| row[HEADER_INDICES[COPYRIGHT_EXP]] }.uniq
      # In Copyright vals are the same for all rows
      if in_cp_vals.size == 1
        if valid_in_copyright_val?(in_cp_vals[0])
          if cp_exp_vals.size <= 1
            in_cp =  in_copyright?(in_cp_vals[0])
            d = valid_date?(cp_exp_vals[0])
            if in_cp
              if d && Date.today < d
                # valid later CP date so check if the avalon item has been modified in RMD
                if default_status?(ai)
                  pad = PastAccessDecision.new(avalon_item: ai, changed_by: 'spreadsheet ingest', copyright_librarian: false, decision: AccessDeterminationHelper::IU_ACCESS)
                  ai.reason_in_copyright = true
                  ai.past_access_decisions << pad
                  ai.current_access_determination == pad
                  ai.recordings.each do |r|
                    r.in_copyright == 'true'
                    r.copyright_end_date = d
                    r.save!
                  end
                  ai.review_state = AvalonItem::REVIEW_STATE_ACCESS_DETERMINED
                  ai.save!
                  GOOD[ai].each do |row|
                    row << "ACCESS SET: IU ONLY"
                    PASSED << row
                  end
                else
                  GOOD[ai].each do |row|
                    row << "FAILED: access has already been set in RMD"
                    FAILED << row
                  end
                end
              elsif d && Date.today >= d
                # FAILED: In CP yes and earlier cp exp than today indicates a 1/1/50 type original date. This should have
                # indicated a 1/1/2050 date but was corrected in the original spreadsheet as 1/1/1950 so fail it
                GOOD[ai].each do |row|
                  row << "FAILED: In Copyright YES but Expiration date is past."
                  FAILED << row
                end
              elsif ! d
                GOOD[ai].each do |row|
                  row << "FAILED: In Copyright YES but no or illegible Expiration date present."
                  FAILED << row
                end
              else
                raise "HERE!"
              end
            elsif !in_cp
              # d will be a Date object or nil, so check the exp val from the spreadsheet for blank
              if cp_exp_vals[0].blank?
                if default_status?(ai)
                  pad = PastAccessDecision.new(avalon_item: ai, changed_by: 'spreadsheet ingest', copyright_librarian: false, decision: AccessDeterminationHelper::WORLD_WIDE_ACCESS)
                  ai.reason_public_domain = true
                  ai.past_access_decisions << pad
                  ai.current_access_determination == pad
                  ai.recordings.each do |r|
                    r.in_copyright == 'true'
                    r.save!
                  end
                  ai.review_state = AvalonItem::REVIEW_STATE_ACCESS_DETERMINED
                  ai.save!
                  GOOD[ai].each do |row|
                    row << "ACCESS SET: Worldwide Access (In Copyright NO and blank expiration date.)"
                    PASSED << row
                  end
                else
                  GOOD[ai].each do |row|
                    row << "FAILED: access has already been set in RMD"
                    FAILED << row
                  end
                end
              else
                if (d && Date.today > d)
                  if default_status?(ai)
                    pad = PastAccessDecision.new(avalon_item: ai, changed_by: 'spreadsheet ingest', copyright_librarian: false, decision: AccessDeterminationHelper::WORLD_WIDE_ACCESS)
                    ai.reason_public_domain = true
                    ai.past_access_decisions << pad
                    ai.current_access_determination == pad
                    ai.recordings.each do |r|
                      r.in_copyright == 'true'
                      r.copyright_end_date = d
                      r.save!
                    end
                    ai.review_state = AvalonItem::REVIEW_STATE_ACCESS_DETERMINED
                    ai.save!
                    GOOD[ai].each do |row|
                      row << "ACCESS SET: Worldwide Access (In Copyright NO and past expiration date.)"
                      PASSED << row
                    end
                  else
                    GOOD[ai].each do |row|
                      row << "FAILED: access has already been set in RMD"
                      FAILED << row
                    end
                  end
                elsif (d && Date.today < d)
                  GOOD[ai].each do |row|
                    row << "FAILED: In Copyright NO but future expiration date"
                    FAILED << row
                  end
                elsif !d
                  GOOD[ai].each do |row|
                    row << "FAILED: In Copyright NO but unparseable expiration date"
                    FAILED << row
                  end
                else
                  raise "HOW?!?!"
                end
              end
            end
          else
            GOOD[ai].each do |row|
              row << "FAILED: multiple different 'Copyright Expiration Date' values: [#{cp_exp_vals.join(',')}]"
            end
          end
        else
          GOOD[ai].each do |row|
            row << "FAILED: illegible 'In Copyright' value"
            FAILED << row
          end
        end
      elsif in_cp_vals.size == 0
        GOOD[ai].each do |row|
          row << "FAILED: no 'In Copyright' value present."
          FAILED << row
        end
      else
        GOOD[ai].each do |row|
          row << "FAILED: multiple different 'In Copyright' values: [#{in_cp_vals.join(',')}]"
          FAILED << row
        end
      end
    end
  end

  def self.total_found
    FAILED.size + PASSED.size + NOT_DIGITIZED.size + NOT_IULMIA.size + NOT_IN_RMD.size
  end

  private
  def self.iulmia?(unit_name)
    unit_name == IULMIA_UNIT_NAME
  end

  def self.all_present?(avalon_item)
    avalon_item.recordings.each do |r|
      return false if BC_MAP[r.mdpi_barcode.to_s].nil?
    end
    true
  end

  def self.default_status?(ai)
    ai.current_access_determination.decision == AccessDeterminationHelper::DEFAULT_ACCESS
  end

  def self.move_to_failed(avalon_item, msg)
    avalon_item.recordings.each do |r|
      row = BC_MAP[r.mdpi_barcode.to_s]
      row << msg unless row.nil?
      FAILED << row unless row.nil?
    end
  end

  def self.move_to_passed(avalon_item, msg)
    avalon_item.recordings.each do |r|
      row = BC_MAP[r.mdpi_barcode.to_s]
      # the row has to exist so no need to nil? check
      row << msg
      PASSED << row
    end
  end

  # checks if all Recordings of the AvalonItem have the same copyright status and copyright expiration date in
  # the spreadsheet
  def self.same_copyright_status?(avalon_item)
    cp = ""
    cpd = ""
    avalon_item.recordings.each do |r|
      row = BC_MAP[r.mdpi_barcode.to_s]
      if cp.blank?
        cp = row[HEADER_INDICES[IN_COPYRIGHT]]
        cpd = row[HEADER_INDICES[COPYRIGHT_EXP]]
      else
        if row[HEADER_INDICES[IN_COPYRIGHT]] != cp || row[HEADER_INDICES[COPYRIGHT_EXP]] != cpd
          return false
        end
      end
    end
    return true
  end

  def self.valid_in_copyright_val?(value)
    return false if value.blank?
    v = value.downcase.strip
    !v.blank? && (v == "y" || v == 'yes' || v == "n" || v == 'no' )
  end

  def self.in_copyright?(value)
    # an item is in copyright unless it EXPLICITLY says it is not
    if !value.blank? && (value.downcase.strip == "n" || value.downcase.strip == "no")
      false
    elsif !value.blank? && (value.downcase.strip == "y" || value.downcase.strip == 'yes')
      true
    else
      raise "In Copyright value not checked with valid_in_copyright_val? prior to calling this. Or there's a bug in that code..."
    end
  end

  # returns a Date object if true otherwise false
  def self.valid_date?(date_text)
    begin
      # the date should be formatted this way
      Date.strptime(date_text, "%Y-%m-%d")
    rescue
      begin
        # but some dates were formatted this way
        Date.strptime(date_text, "%d/%m/%Y")
      rescue
        false
      end
    end
  end

  def self.write_to_files
    passed = @@DIR_NAME+"passed.csv"
    failed = @@DIR_NAME+"failed.csv"
    not_iulmia = @@DIR_NAME+"not_iulmia.csv"
    not_rmd = @@DIR_NAME+"not_in_rmd.csv"
    write_to_file(PASSED, passed)
    write_to_file(FAILED, failed)
    write_to_file(NOT_IULMIA, not_iulmia)
    write_to_file(NOT_IN_RMD, not_rmd)
  end

  def self.write_to_file(rows, file)
    puts "\t\tWriting #{file}"
    CSV.open( file, 'w' ) do |writer|
      writer << @@HEADER
      rows.each do |row|
        writer << row
      end
    end
    puts "\t\t\tDone!"
  end

end

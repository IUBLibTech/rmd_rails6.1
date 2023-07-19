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
  FOUND_AVALON_ITEMS = []

  # any row from the IULMIA spreadsheet that failed
  FAILED = []
  NOT_IN_RMD = []
  PASSED = []
  NOT_DIGITIZED = []
  NOT_IULMIA = []

  @@DIR_NAME = "#{Rails.root}/tmp/adss/"

  def self.parse_spreadsheet(file_path=DEFAULT_LOCATION)
    rows = CSV.read(file_path)
    header = rows[0]
    FAILED << header
    PASSED << header
    NOT_DIGITIZED << header
    NOT_IULMIA << header
    NOT_IN_RMD << header
    index = 1
    while(index < rows.size)
      puts "\n\tProcessing row #{index} of #{rows.size}\n"
      row = rows[index]
      if (iulmia?(row[HEADER_INDICES[UNIT]]))
        bc = row[HEADER_INDICES[MDPI_BC]]
        if (bc.blank?)
          NOT_DIGITIZED << row
        else
          r = Recording.where(mdpi_barcode: bc)
          if r.size == 0
            row << "Not in RMD"
            NOT_IN_RMD << row
          elsif r.size == 1
            BC_MAP[r.first.mdpi_barcode.to_s] = row
            FOUND_AVALON_ITEMS << r.first.avalon_item
          elsif r.size > 1
            # two possibilities here
            # a) the source recording was digitized into multiple files (cassette, LP, multiple playback speed video, etc) or
            # b) this barcode appears in two or more AvalonItems.
            ais = r.collect{|r| r.avalon_item}.uniq
            if ais.size == 1
              BC_MAP[r.first.mdpi_barcode.to_s] = row
              FOUND_AVALON_ITEMS << ais.first
            else
              row << "MDPI barcode appears in multiple AvalonItems"
              FAILED << row
            end
          else
            raise "How is this possible?!?!"
          end
        end
      else
        NOT_IULMIA << row
      end
      index += 1
    end

    # now iterate through FOUND_AVALON_ITEMS to check if everything needed is present in the spreadsheet
    FOUND_AVALON_ITEMS.each do |ai|
      # are all POs present in the spreadsheet?
      if all_present?(ai)
        # do all POs have the same copyright status and expiration date?
        if same_copyright_status?(ai)
          if default_status?(ai)
            row = BC_MAP[ai.recordings.first.mdpi_barcode.to_s]
            if valid_in_copyright_val?(row[HEADER_INDICES[IN_COPYRIGHT]])
              if in_copyright?(row[HEADER_INDICES[IN_COPYRIGHT]])
                exp = valid_date?(row[HEADER_INDICES[COPYRIGHT_EXP]])
                if exp
                  if exp <= Date.today
                    move_to_failed(ai, "(Multiple POs) In Copyright: yes but expiration Date expired.")
                  else
                    pad = PastAccessDecision.new(avalon_item_id: ai.id, decision: "IU Access - Reviewed", changed_by: "spreadsheet")
                    ai.reason_in_copyright = true
                    ai.past_access_decisions << pad
                    ai.current_access_determination = pad
                    puts "Saving AvalonItem Access Determination: #{ai.title}"
                    #ai.save!
                    ai.recordings.each do |r|
                      r.in_copyright = "true"
                      r.copyright_end_date = exp
                      #r.save!
                      puts "\tSaving Recording: #{r.mdpi_barcode}"
                    end
                    move_to_passed(ai, "(Multiple POs) In Copyright: yes, and valid future expiration. IU Access - Reviewed")
                  end
                else
                  move_to_failed(ai, "(Multiple POs) Invalid Copyright Expiration Date")
                end
              else
                # if the item is listed as NOT in copyright, the only error is if there is a future or malformed
                # expiration date
                row = BC_MAP[ai.recordings.first.mdpi_barcode.to_s]
                d = row[HEADER_INDICES[COPYRIGHT_EXP]]
                exp = valid_date?(d)
                if d.blank? || (exp && exp <= Date.today)
                  pad = PastAccessDecision.new(avalon_item_id: ai.id, decision: "World Wide Access", changed_by: "spreadsheet")
                  ai.reason_public_domain = true
                  ai.past_access_decisions << pad
                  ai.current_access_determination = pad
                  puts "Saving AvalonItem: #{ai.title}"
                  #ai.save!
                  ai.recordings.each do |recording|
                    recording.in_copyright = "false"
                    recording.copyright_end_date = d
                    recording.copyright_end_date = exp
                    puts "\tSaving Recording: #{recording.mdpi_barcode}"
                    #recording.save!
                  end
                  move_to_passed(ai, "(Multiple POs) In Copyright: no and Blank or Passed expiration. Worldwide Access")
                else
                  move_to_failed(ai, "(Multiple POs) In Copyright: no but invalid Copyright Expiration Date")
                end
              end
            else
              move_to_failed(ai, "(Multiple POs) Indeterminate 'In Copyright Y/N' value.")
            end
          else
            move_to_failed(ai, "(Multiple POs) Access already set in RMD to: #{ai.current_access_determination.decision}")
          end
        else
          move_to_failed(ai, "(Multiple POs) Differing In Copyright Statuses and/or Copyright Expiration Dates ")
        end
      else
        move_to_failed(ai, "(Multiple POs) not all barcodes present in spreadsheet")
      end
    end
    write_to_files
    return nil
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
    ai.current_access_determination.decision == "Default IU Access - Not Reviewed"
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
  def self.valid_date?(date)
    begin
      Date.strptime(date, "%Y-%m-%d")
    rescue
      false
    end
  end

  def self.write_to_files
    passed = @@DIR_NAME+"passed.csv"
    failed = @@DIR_NAME+"failed.csv"
    not_digitized = @@DIR_NAME+"not_digitized.csv"
    not_iulmia = @@DIR_NAME+"not_iulmia.csv"
    write_to_file(PASSED, passed)
    write_to_file(FAILED, failed)
    write_to_file(NOT_DIGITIZED, not_digitized)
    write_to_file(NOT_IULMIA, not_iulmia)
  end

  def self.write_to_file(rows, file)
    puts "\t\tWriting #{file}"
    CSV.open( file, 'w' ) do |writer|
      rows.each do |row|
        writer << row
      end
    end
    puts "\t\t\tDone!"
  end

end

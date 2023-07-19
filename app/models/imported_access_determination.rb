class ImportedAccessDetermination < ApplicationRecord
  require "roo"

  belongs_to :avalon_item, optional: true

  MCO_PURL = "MCO_PURL", CAT_KEY = "CAT_KEY", CALL_NUMBER = "CALL_NUMBER", PUBLIC_DOMAIN = "PUBLIC_DOMAIN",
    PUBLIC_DOMAIN_DATE = "PUBLIC_DOMAIN_DATE", IU_OWNED = "IU_OWNED", LICENSED_WORLDWIDE = "LICENSED_WORLDWIDE",
    LICENSE_EXPIRATION = "LICENSE_EXPIRATION", WHO_PERFORMED = "WHO_PERFORMED", WHO_OPENED = "WHO_OPENED",
    OPENED_DATE = "OPENED_DATE", COMMENTS = "COMMENTS"

  # column indices where above appears in the spreadsheets
  HEADER_INDICES = {
    MCO_PURL => 0, CAT_KEY => 1, CALL_NUMBER => 2, PUBLIC_DOMAIN => 3, PUBLIC_DOMAIN_DATE => 4, IU_OWNED => 5,
    LICENSED_WORLDWIDE => 6, LICENSE_EXPIRATION => 7, WHO_PERFORMED => 8, WHO_OPENED => 9, OPENED_DATE => 10, COMMENTS => 11
  }


  def self.import_spreadsheet(filepath)
    sheet = Roo::Spreadsheet.open(filepath, extension: :xlsx)
    sheet.default_sheet = sheet[0]
    i = 2 # skip the header row
    while (i <= sheet.last_row)
      row = sheet.row(i)
      unless row[HEADER_INDICES[MCO_PURL]].blank?
        ImportedAccessDetermination.new(
          spreadsheet_name: filepath.split('/').last,
          mco_purl: row[HEADER_INDICES[MCO_PURL]],
          catalog_key: row[HEADER_INDICES[CAT_KEY]],
          call_number: row[HEADER_INDICES[CALL_NUMBER]],
          public_domain: parse_boolean(row[HEADER_INDICES[PUBLIC_DOMAIN]]),
          enters_public_domain: parse_date(row[HEADER_INDICES[PUBLIC_DOMAIN_DATE]]),
          iu_owns_copyright: parse_boolean(row[HEADER_INDICES[IU_OWNED]]),
          licensed_for_worldwide_access: parse_boolean(row[HEADER_INDICES[LICENSED_WORLDWIDE]]),
          license_expiration_date: parse_date(row[HEADER_INDICES[LICENSE_EXPIRATION]]),
          who_performed_research: row[HEADER_INDICES[WHO_PERFORMED]],
          who_made_open: row[HEADER_INDICES[WHO_OPENED]],
          date_made_open: parse_date(row[HEADER_INDICES[OPENED_DATE]]),
          comments: row[HEADER_INDICES[COMMENTS]],
        ).save!
      end
      i += 1
    end
  end

  # returns nil if text is blank, or anything other that Y/N or Yes/No (ignoring case), otherwise translates acceptible
  # text into a boolean value
  def self.parse_boolean(text)
    return nil if text.blank?
    return true if text.downcase == "y" || text.downcase == "yes"
    return false if text.downcase == "n" || text.downcase == "no"
    return nil
  end

  def self.parse_date(text)
    return nil if text.blank?
    return nil unless text.match /^\d{8}$/
    return Date.strptime(text, "%Y%m%d")
  end

  def avalon_id
    mco_purl&.split("/")&.last
  end

end

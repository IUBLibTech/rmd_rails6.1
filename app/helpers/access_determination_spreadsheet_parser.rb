module AccessDeterminationSpreadsheetParser
  require 'roo'
  HEADERS = [
    "MCO PURL",	"Catalog Key",	"Call Number/ Local Identifier",	"Public Domain?   (Y or N)",	"Date it did or will enter PD      (YYYYMMDD)",
    "University Own Copyright? (Y or N)",	"University Licensed for Worldwide Access? (Y or N)",	"License Expiration Date (YYYYMMDD)",
    "Who performed the Copyright Research? (USERNAME)",	"User who made open (USERNAME)",	"Date made open (YYYYMMDD)",	"Comments/Notes"
  ]


  def self.parse_spreadsheets
    ss = Dir.glob("#{Rails.application.root}/tmp/adss/*");
    ss.each do |s|
      if (s.end_with?(".xlsx") || s.end_with?(".xls"))
        puts s
        x = Roo::Spreadsheet.open(s,extension: :xlsx)
        puts x.sheets
        x.default_sheet = x.sheets[0]

      else
        puts "wtf"
      end
    end
  end

  def self.parse_sheet(sheet)

  end



end
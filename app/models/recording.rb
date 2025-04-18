class Recording < ApplicationRecord
  include AccessDeterminationHelper

  has_many :recording_performances, dependent: :destroy
  has_many :recording_notes, dependent: :destroy
  has_many :performances, through: :recording_performances, dependent: :destroy

  # this one is wonky because recording_contributor_people holds the role booleans (producer and depositor). A Person only
  # contributes if a role is set. But the RecordingContributorPerson can exist with any roles being set to true so we have
  # to abstract the actual people through the middle query of :contributors
  has_many :recording_contributor_people
  has_many :contributors, -> { where "recording_producer = true OR recording_depositor = true" }, class_name: "RecordingContributorPerson"
  has_many :people, through: :contributors

  after_destroy :killed


  belongs_to :atom_feed_read
  belongs_to :avalon_item
  has_one :pod_physical_object, class_name: 'PodPhysicalObject', foreign_key: 'mdpi_barcode', primary_key: 'mdpi_barcode'
  has_one :pod_unit, through: :pod_physical_object

  accepts_nested_attributes_for :recording_notes, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :performances

  before_save :edtf_dates

  after_save :update_avalon_items

  UNITS = ["B-AAAI", "B-AAAMC", "B-AFRIST", "B-ALF", "B-ANTH", "B-ARCHIVES", "B-ASTR", "B-ATHBASKM", "B-ATHBASKW",
           "B-ATHFHOCKEY", "B-ATHFTBL", "B-ATHROWING", "B-ATHSOCCM", "B-ATHSOFTB", "B-ATHTENNM", "B-ATHVIDEO",
           "B-ATHVOLLW", "B-ATM", "B-BCC", "B-BFCA", "B-BUSSPEA", "B-CAC", "B-CDEL", "B-CEDIR", "B-CELCAR", "B-CELTIE",
           "B-CEUS", "B-CHEM", "B-CISAB", "B-CLACS", "B-CMCL", "B-CREOLE", "B-CSHM", "B-CYCLOTRN", "B-EASC", "B-EDUC",
           "B-EPPLEY", "B-FACILITY", "B-FINEARTS", "B-FOLKETHNO", "B-FRANKLIN", "B-GBL", "B-GEOLOGY", "B-GLBTSSSL",
           "B-GLEIM", "B-GLOBAL", "B-HPER", "B-IAS", "B-IAUNRC", "B-IPRC", "B-IUAM", "B-IULMIA", "B-JOURSCHL", "B-KINSEY",
           "B-LACASA", "B-LAW", "B-LIBERIA", "B-LIFESCI", "B-LILLY", "B-LING", "B-MATHERS", "B-MDP", "B-MUSBANDS", "B-MUSIC",
           "B-MUSOPERA", "B-MUSREC", "B-OID", "B-OPTMSCHL", "B-OPTOMTRY", "B-POLISH", "B-PSYCH", "B-RECSPORTS", "B-REEI",
           "B-RTVS", "B-SAGE", "B-SAVAIL", "B-SWAIN", "B-TAI", "B-THTR", "B-UNDRWATR", "B-UNIVCOMM", "B-WELLS", "B-WEST",
           "EA-ARCHIVES", "EA-ATHL", "I-ARCHIVES", "I-DENT", "I-LIBR-SCA", "I-RAYBRAD", "KO-ARCHIVES", "NW-ARCHIVES",
           "SB-ARCHIVES", "SB-PHYS", "SB-ULIB", "SE-ARCHIVES"]

  validates :access_determination, :inclusion => {:in => ACCESS_DECISIONS}

  def contributors
    people.map { |p| p.name }
  end

  def edtf_dates
    # copyright end date
    date = Date.edtf(copyright_end_date_text.gsub('/', '-'))
    self.copyright_end_date = date
    puts "Set copyright_end_date to #{date}, calling self.copyright_end_date: #{self.copyright_end_date}"

    # creation date
    date = Date.edtf(creation_date_text.gsub('/', '-'))
    self.creation_date = date
    #puts "Set creation_date to #{date}, calling self.creation_date: #{self.creation_date}"

    # date of first pub
    date = Date.edtf(date_of_first_publication_text.gsub('/', '-'))
    self.date_of_first_publication = date
    #puts "Set date_of_first_publication to #{date}, calling self.date_of_first_publication: #{self.date_of_first_publication}"
  end

  private
  def update_avalon_items
    avalon_item.update(structure_modified: true)
  end

  def killed
    puts "#{self.class}:#{self.id} destroyed!"
  end
end

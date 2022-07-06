class Person < ApplicationRecord
  before_save :edtf_dates
  has_many :person_nationalities
  has_many :nationalities, through: :person_nationalities

  has_many :person_iu_affiliations
  has_many :iu_affiliations, through: :person_iu_affiliations

  has_many :recording_contributor_people
  has_many :recordings, through: :recording_contributor_people

  has_many :performance_contributor_people
  has_many :performances, through: :performance_contributor_people

  has_many :track_contributor_people
  has_many :contributions, -> { where "interviewer = true OR interviewee = true OR conductor = true OR performer = true" }, class_name: "TrackContributorPerson"
  has_many :tracks, through: :contributions

  has_many :avalon_items, through: :recordings

  has_many :work_contributor_people
  has_many :works, through: :work_contributor_people

  before_save :clear_person_entity

# for json population
#   attr_accessor :value
#   attr_accessor :label

  RECORDING_CONTRIBUTOR_ROLES_KEY = "recording"
  PERFORMANCE_CONTRIBUTOR_ROLES_KEY = "performance"
  TRACK_CONTRIBUTOR_ROLES_KEY = "track"
  WORK_CONTRIBUTOR_ROLES_KEY = "work"
  ROLES = {
      RECORDING_CONTRIBUTOR_ROLES_KEY => ["Depositor (R)", "Recording Producer (R)"],
      TRACK_CONTRIBUTOR_ROLES_KEY => ["Interviewer (P)", "Performer (P)", "Conductor (P)", "Interviewee (P)"],
      WORK_CONTRIBUTOR_ROLES_KEY => ["Contributor (W)", "Principle Creator (W)"]
  }
  ALL_ROLES = Person::ROLES.keys.collect{|k| Person::ROLES[k]}.flatten.sort

  searchable do
    text :aka
    text "name" do
      if entity?
        "#{company_name}"
      else
        "#{full_name}"
      end
    end
  end

  def self.solr_search(term)
    p = Person.search do fulltext term end
    p.results
  end

  def name
    "#{first_name} #{last_name}"
  end
  def full_name_last_first
    "#{last_name}, #{first_name}#{middle_name.blank? ? '' : " #{middle_name}"}"
  end
  def full_name
    "#{first_name}#{middle_name.blank? ? '' : " "+middle_name} #{last_name}"
  end

  def label
    self.entity? ? company_name : full_name
  end
  def value
    id
  end

  def birth_death_text
    if date_of_birth_edtf.blank? && date_of_death_edtf.blank?
      ""
    else
      "#{date_of_birth_edtf} - #{date_of_death_edtf}"
    end
  end

  def recording_producer?(r_id)
    recording_contributor_people.where(recording_id: r_id, recording_producer: true).size > 0
  end
  def recording_depositor?(r_id)
    recording_contributor_people.where(recording_id: r_id, recording_depositor: true).size > 0
  end

  def track_interviewer?(t_id)
    track_contributor_people.where(track_id: t_id, interviewer: true).size > 0
  end
  def track_performer?(t_id)
    track_contributor_people.where(track_id: t_id, performer: true).size > 0
  end
  def track_conductor?(t_id)
    track_contributor_people.where(track_id: t_id, conductor: true).size > 0
  end
  def track_interviewee?(t_id)
    track_contributor_people.where(track_id: t_id, interviewee: true).size > 0
  end

  def track_contributor?(t_id)
    track_contributor_people.where(track_id: t_id, contributor: true).size > 0
  end

  def as_json(options)
    super(methods: [:label, :value])
  end

  # This method ensures that when an EDTF text date is modified (added, changed or removed), that the underlying
  # DB Date reflects that
  def edtf_dates
    date = Date.edtf(date_of_birth_edtf&.gsub('/', '-'))
    self.date_of_birth = date
    puts "Set date_of_birth to #{date}, calling self.date_of_birth: #{self.date_of_birth}"

    date = Date.edtf(date_of_death_edtf&.gsub('/', '-'))
    self.date_of_death = date
    puts "Set date_of_death to #{date}, calling self.date_of_death: #{self.date_of_death}"
  end

# if a person is changed to an entity, or vice versa, clear the no-longer-relevant fields
  def clear_person_entity
    if self.entity?
      first_name = middle_name = last_name = date_of_birth = date_of_death = date_of_birth_edtf =
        date_of_death_edtf = place_of_birth = nil
    else
      company_name = entity_nationality = nil
    end
  end


end

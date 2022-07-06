class Work < ApplicationRecord
  has_many :work_contributor_people
  has_many :people, through: :work_contributor_people

  has_many :track_works
  has_many :tracks, through: :track_works
  has_many :performances, through: :tracks
  has_many :avalon_items, through: :performances
  # alias_attribute :work_contributors, :people
  before_save :edtf_dates

  searchable do
    text :title, :alternative_titles
  end

  def self.solr_search(term)
    w = Work.search do fulltext term end
    w.results
  end
  # This method ensures that when an EDTF text date is modified (added, changed or removed), that the underlying
  # DB Date reflects that
  def edtf_dates
    date = Date.edtf(publication_date_edtf.gsub('/', '-'))
    self.publication_date = date
    puts "Set publication_date to #{date}, calling self.publication_date: #{self.publication_date}"

    date = Date.edtf(copyright_end_date_edtf.gsub('/', '-'))
    self.copyright_end_date = date
    puts "Set copyright_end_date to #{date}, calling self.copyright_end_date: #{self.copyright_end_date}"
  end
  def label
    title
  end
  def value
    id
  end
  def as_json(options)
    json = super(methods: [:label, :value])
    Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  end

  def performed_on_track?(tid)
    track_works.where(track_id: tid).size > 0
  end

  def principle_creator?(person_id)
    work_contributor_people.where(person_id: person_id, principle_creator: true).any?
  end
  def contributor?(person_id)
    work_contributor_people.where(person_id: person_id, contributor: true).any?
  end

  def roles(person)
    roles = []
    wc = work_contributor_people.where("person_id = ? and (principle_creator = true OR contributor = true)", person.id)
    wc.each do |c|
      roles << "Principle Creator" if c.principle_creator?
      roles << "Contributor" if c.contributor?
    end
    roles.distinct
  end


end

class Performance < ApplicationRecord
  has_many :recording_performances
  has_many :recordings, through: :recording_performances
  has_many :tracks, dependent: :delete_all
  has_many :performance_notes
  # no longer contributions at this level, only at recording and track level
  # has_many :performance_contributor_people
  # has_many :contributors, -> { where "interviewer = true OR interviewee = true OR performer = true OR conductor = true" }, class_name: "PerformanceContributorPerson"
  # has_many :people, through: :contributors
  has_many :avalon_items, through: :recordings

  accepts_nested_attributes_for :tracks

  before_save :edtf_dates
  before_update :edtf_dates
  after_save :update_avalon_items

  def performance_date_string=(str)
    super
  end

  def edtf_dates
    if performance_date_string.nil?
      self.performance_date = nil
    else
      date = Date.edtf(performance_date_string.gsub('/', '-'))
      self.performance_date = date
      puts "Set performance_date to #{date}, calling self.performance_date: #{self.performance_date}"
    end
  end

  private
  def update_avalon_items
    avalon_items.update_all(structure_modified: true)
  end

end

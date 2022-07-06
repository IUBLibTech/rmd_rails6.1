class Track < ApplicationRecord
  belongs_to :performance
  has_many :track_works
  has_many :works, through: :track_works
  has_many :track_contributor_people
  has_many :contributors, -> { where "interviewer = true OR interviewee = true OR conductor = true OR performer = true" }, class_name: "TrackContributorPerson"
  has_many :people, through: :contributors

  before_save :edtf_dates
  after_save :update_avalon_items


  # recording_start_time is input as hh:mm:ss but stored as seconds
  def recording_start_time=(time)
    if time.blank?
      super(nil)
    else
      super(time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b})
    end
  end

  def recording_start_time
    unless super.nil?
      hh_mm_sec(super)
    end
  end

  def recording_end_time=(time)
    if time.blank?
      super(nil)
    else
      super(time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b})
    end
  end

  def recording_end_time
    unless super.nil?
      hh_mm_sec(super)
    end
  end

  def edtf_dates
    if copyright_end_date_text.nil?
      self.copyright_end_date = nil
    else
      date = Date.edtf(copyright_end_date_text.gsub('/', '-'))
      self.copyright_end_date = date
      puts "Set Track copyright_end_date to #{date}, calling self.copyright_end_date: #{self.copyright_end_date}"
    end
  end

  def hh_mm_sec(totalSeconds)
    hh = (totalSeconds / 3600).floor
    mm = ((totalSeconds - (hh * 3600)) / 60).floor
    ss = totalSeconds - (hh * 3600) - (mm * 60)
    "#{hh}:#{"%02d" % mm}:#{"%02d" % ss}"
  end

  private
  def update_avalon_items
    performance.avalon_items.update_all(structure_modified: true)
  end
end

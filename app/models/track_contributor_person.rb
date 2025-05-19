class TrackContributorPerson < ApplicationRecord
  belongs_to :person
  belongs_to :track

  # returns a human readable string displaying any set roles for the person/track combo
  def roles_text
    roles = []
    roles << "Interviewer" if self.interviewer
    roles << "Interviewee" if self.interviewee
    roles << "Performer" if self.performer
    roles << "Conductor" if self.conductor
    roles.join(", ")
  end
end

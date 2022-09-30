class RecordingContributorPerson < ApplicationRecord
  belongs_to :recording
  belongs_to :person

  # how roles, contracts and policies are handled has changed. There is no longer an association between these object,
  # the role is now stored in THIS object, contracts have been extrapolated into their own thing, and policies have been
  # folded into contracts (Called Legal Agreements in the applicaiton)
  # belongs_to :role
  # belongs_to :contract
  # belongs_to :policy

  def roles_text
    roles = []
    roles << "Recording Depositor" if self.recording_depositor
    roles << "Recording Producer" if self.recording_producer
    roles.join(", ")
  end
end

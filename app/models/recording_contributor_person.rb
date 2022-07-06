class RecordingContributorPerson < ApplicationRecord
  belongs_to :recording
  belongs_to :role
  belongs_to :contract
  belongs_to :person
  belongs_to :policy
end

class TrackContributorPerson < ApplicationRecord
  belongs_to :person
  belongs_to :track
end

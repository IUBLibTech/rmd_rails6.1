class WorkContributorPerson < ApplicationRecord
  belongs_to :work
  belongs_to :person
end

class PerformanceContributorPerson < ApplicationRecord
  belongs_to :performance
  belongs_to :person
  belongs_to :contract
  belongs_to :role
end

class WorkContributor < ApplicationRecord
  belongs_to :work
  belongs_to :role
  belongs_to :person
end

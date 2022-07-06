class Role < ApplicationRecord
  # this class is no longer used - roles have been moved into performance_contributor_people, work_contributor_people, etc
  # has_many :people, through: :work_contributor_people
  # has_many :works, through: :work_contributor_people
  # has_many :performance_contributors
  # has_many :people, as: :performers
end

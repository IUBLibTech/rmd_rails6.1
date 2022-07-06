class Nationality < ApplicationRecord
  has_many :person_nationalities
  has_many :people, through: :person_nationalities
end

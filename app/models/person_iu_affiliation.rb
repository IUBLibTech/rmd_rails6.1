class PersonIuAffiliation < ApplicationRecord
  belongs_to :person
  belongs_to :iu_affiliation
end

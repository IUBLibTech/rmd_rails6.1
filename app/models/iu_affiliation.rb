class IuAffiliation < ApplicationRecord
  has_many :person_iu_affiliates
  has_many :people, through: :person_iu_affiliates
end

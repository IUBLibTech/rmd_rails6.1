class PersonNationality < ApplicationRecord
  belongs_to :person
  belongs_to :nationality
end

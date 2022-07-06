class CreatePersonIuAffiliations < ActiveRecord::Migration[4.2]
  def change
    create_table :person_iu_affiliations do |t|
      t.integer :person_id, limit: 8
      t.integer :iu_affiliation_id
      t.date :begin_date
      t.date :end_date
      t.timestamps null: false
    end
  end
end

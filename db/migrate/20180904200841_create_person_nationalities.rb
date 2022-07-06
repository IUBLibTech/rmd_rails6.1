class CreatePersonNationalities < ActiveRecord::Migration[4.2]
  def change
    create_table :person_nationalities do |t|
      t.integer :person_id, limit: 8
      t.integer :nationality_id, limit: 8
      t.date :begin_date
      t.date :end_date
      t.timestamps null: false
    end
  end
end

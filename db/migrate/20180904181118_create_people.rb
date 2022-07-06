class CreatePeople < ActiveRecord::Migration[4.2]
  def change
    create_table :people do |t|
      t.string :name
      t.date :date_of_birth
      t.date :date_of_death
      t.string :place_of_birth
      t.string :authority_source
      t.string :aka
      t.text :notes
      t.timestamps null: false
    end
  end
end

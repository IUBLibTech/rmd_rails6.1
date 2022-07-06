class CreateTrackContributorPeople < ActiveRecord::Migration[4.2]
  def change
    create_table :track_contributor_people do |t|
      t.integer :track_id, limit: 8
      t.integer :person_id, limit: 8
      t.string :role
      t.timestamps null: false
    end
  end
end

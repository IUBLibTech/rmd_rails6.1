class CreateRecordingContributorPeople < ActiveRecord::Migration[4.2]
  def change
    create_table :recording_contributor_people do |t|
      t.integer :contract_id, limit: 8
      t.integer :recording_id, limit: 8
      t.integer :role_id, limit: 8
      t.integer :person_id, limit: 8
      t.integer :policy_id, limit: 8
      t.boolean :relationship_to_depositor
      t.text :notes
      t.timestamps null: false
    end
  end
end

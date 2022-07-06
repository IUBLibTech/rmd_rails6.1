class CreateWorkContributorPeople < ActiveRecord::Migration[4.2]
  def change
    create_table :work_contributor_people do |t|
      t.integer :work_id, limit: 8
      t.integer :person_id, limit: 8
      t.integer :role_id, limit: 8
      t.timestamps null: false
    end
  end
end

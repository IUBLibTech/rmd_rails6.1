class CreatePastAccessDecisions < ActiveRecord::Migration[4.2]
  def change
    create_table :past_access_decisions do |t|
      t.integer :recording_id, limit: 8
      t.string :decision
      t.string :changed_by
      t.timestamps null: false
    end
  end
end

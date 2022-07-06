class CreateRecordingPerformances < ActiveRecord::Migration[4.2]
  def change
    create_table :recording_performances do |t|
      t.integer :recording_id, limit: 8
      t.integer :performance_id, limit: 8
      t.timestamps null: false
    end
  end
end

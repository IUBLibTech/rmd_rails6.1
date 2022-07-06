class CreatePerformanceNotes < ActiveRecord::Migration[4.2]
  def change
    create_table :performance_notes do |t|
      t.integer :performance_id, limit: 8, null: false
      t.text :text
      t.string :creator, null: false
      t.timestamps null: false
    end
  end
end

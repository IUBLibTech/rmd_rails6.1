class CreatePerformances < ActiveRecord::Migration[4.2]
  def change
    create_table :performances do |t|
      t.integer :work_id, limit: 8
      t.string :location
      t.date :performance_date
      t.string :notes
      t.string :access_determination
      t.boolean :in_copyright
      t.date :copyright_end_date
      t.timestamps null: false
    end
  end
end

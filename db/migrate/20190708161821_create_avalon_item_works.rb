class CreateAvalonItemWorks < ActiveRecord::Migration[4.2]
  def change
    create_table :avalon_item_works do |t|
      t.integer :avalon_item_id, limit: 8
      t.integer :work_id, limit: 8
      t.timestamps null: false
    end
  end
end

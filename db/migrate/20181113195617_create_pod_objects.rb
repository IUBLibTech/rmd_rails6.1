class CreatePodObjects < ActiveRecord::Migration[4.2]
  def change
    create_table :pod_objects do |t|

      t.timestamps null: false
    end
  end
end

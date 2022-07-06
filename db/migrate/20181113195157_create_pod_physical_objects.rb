class CreatePodPhysicalObjects < ActiveRecord::Migration[4.2]
  def change
    create_table :pod_physical_objects do |t|

      t.timestamps null: false
    end
  end
end

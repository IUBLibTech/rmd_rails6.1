class CreatePodWorkflowStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :pod_workflow_statuses do |t|

      t.timestamps null: false
    end
  end
end

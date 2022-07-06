class MovePastAccessDecisionToAllModels < ActiveRecord::Migration[4.2]
  def change
    rename_column :past_access_decisions, :recording_id, :avalon_item_id
  end
end

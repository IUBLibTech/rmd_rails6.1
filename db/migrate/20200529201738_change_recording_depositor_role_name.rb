class ChangeRecordingDepositorRoleName < ActiveRecord::Migration[4.2]
  def change
    rename_column :recording_contributor_people, :depositor_role, :recording_depositor
  end
end

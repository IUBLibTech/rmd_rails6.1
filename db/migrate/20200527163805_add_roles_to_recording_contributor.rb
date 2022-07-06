class AddRolesToRecordingContributor < ActiveRecord::Migration[4.2]
  def change
    add_column :recording_contributor_people, :depositor_role, :boolean
    add_column :recording_contributor_people, :recording_producer, :boolean
  end
end

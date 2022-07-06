class AddLastUpdatedByToRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :last_updated_by, :string
  end
end

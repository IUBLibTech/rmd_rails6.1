class IncreaseRecordingTitleDbSize < ActiveRecord::Migration[4.2]
  def change
    change_column :recordings, :title, :text
  end
end

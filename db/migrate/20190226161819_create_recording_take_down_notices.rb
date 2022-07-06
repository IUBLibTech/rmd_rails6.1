class CreateRecordingTakeDownNotices < ActiveRecord::Migration[4.2]
  def change
    create_table :recording_take_down_notices do |t|
      t.integer :recording_id, limit: 8
      t.integer :take_down_notice_id, limit: 8
      t.timestamps null: false
    end
  end
end

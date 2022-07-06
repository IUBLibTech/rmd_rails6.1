class AddUnitToRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :unit, :string, null: false
  end
end

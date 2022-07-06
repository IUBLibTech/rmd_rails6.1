class AddCommercialFlagToRecordings < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :commercial, :boolean
  end
end

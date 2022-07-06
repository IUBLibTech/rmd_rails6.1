class AddCopyrightEndDateTextToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :copyright_end_date_text, :string
  end
end

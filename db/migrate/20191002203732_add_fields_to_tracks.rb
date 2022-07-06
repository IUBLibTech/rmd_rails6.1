class AddFieldsToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :recording_end_time, :integer
    add_column :tracks, :in_copyright, :boolean
    add_column :tracks, :copyright_end_date, :date
    add_column :tracks, :access_determination, :string
  end
end

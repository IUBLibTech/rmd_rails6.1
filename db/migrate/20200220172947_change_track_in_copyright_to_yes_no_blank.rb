class ChangeTrackInCopyrightToYesNoBlank < ActiveRecord::Migration[4.2]
  def up
    add_column :tracks, :in_copyright_string, :string
    Track.all.each do |t|
      str = ''
      if t.in_copyright != nil && t.in_copyright
        str = 'Yes'
      elsif t.in_copyright != nil && !t.in_copyright
        str = 'No'
      end
      t.update!(in_copyright_string: str)
    end
    remove_column :tracks, :in_copyright
    rename_column :tracks, :in_copyright_string, :in_copyright
  end

  def down
    rename_column :tracks, :in_copyright, :in_copyright_string
    add_column :tracks, :in_copyright, :boolean
    Track.all.each do |t|
      b = nil
      if t.in_copyright_string != '' && t.in_copyright_string == 'Yes'
        b = true
      elsif t.in_copyright_string != '' && t.in_copyright_string == 'No'
        b = false
      end
      t.update!(in_copyright: b)
    end
    remove_column :tracks,:in_copyright_string
  end
end

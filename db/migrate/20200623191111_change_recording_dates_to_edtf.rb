class ChangeRecordingDatesToEdtf < ActiveRecord::Migration[4.2]
  def change
    Recording.update_all(copyright_end_date: nil, date_of_first_publication: nil, creation_date: nil)
    # copyright_end_date this was originally just a YYYY value saved as an int, also add the EDTF text representation of the date
    change_column :recordings, :copyright_end_date, :date
    add_column :recordings, :copyright_end_date_text, :string

    # date of first publication. This was originally a YYYY, need to also add the EDTF text for it
    change_column :recordings, :date_of_first_publication, :date
    add_column :recordings, :date_of_first_publication_text, :string

    # creation date. This was originally a YYYY int. Also add the EDTF text for it
    change_column :recordings, :creation_date, :date
    add_column :recordings, :creation_date_text, :string
  end
end

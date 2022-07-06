class ChangeInCopyrightToText < ActiveRecord::Migration[4.2]
  def change
    change_column :recordings, :in_copyright, :string, default: ''
  end
end

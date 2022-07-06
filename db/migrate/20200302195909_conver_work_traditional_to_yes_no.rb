class ConverWorkTraditionalToYesNo < ActiveRecord::Migration[4.2]
  def change
    change_column :works, :traditional, :string
    change_column :works, :contemporary_work_in_copyright, :string
    change_column :works, :restored_copyright, :string
    change_column :works, :copyright_renewed, :string
  end
end

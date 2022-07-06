class CreateWorks < ActiveRecord::Migration[4.2]
  def change
    create_table :works do |t|
      t.string :title
      t.boolean :traditional
      t.boolean :contemporary_work_in_copyright
      t.boolean :restored_copyright
      t.text :alternative_titles
      t.date :publication_Date
      t.string :authority_source
      t.text :notes
      t.string :access_determination
      t.date :copyright_end_date
      t.timestamps null: false
    end
  end
end

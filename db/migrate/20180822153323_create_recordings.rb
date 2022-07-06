class CreateRecordings < ActiveRecord::Migration[4.2]
  def change
    create_table :recordings do |t|
      t.text :title
      t.text :description, limit: 65535
      t.date :creation_date
      t.boolean :published
      t.date :date_of_first_publication
      t.string :country_of_first_publication
      t.boolean :receipt_of_will_before_90_days_of_death
      t.boolean :iu_produced_recording
      t.date :creation_end_date
      t.string :format
      t.integer :mdpi_barcode, limit: 8
      t.string :authority_source
      t.string :access_determination
      t.boolean :in_copyright
      t.date :copyright_end_date
      t.text :decision_comment, limit: 65535
      t.timestamps null: false
    end
  end
end

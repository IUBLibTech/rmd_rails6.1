class CreateImportedAccessDeterminations < ActiveRecord::Migration[6.1]
  def change
    create_table :imported_access_determinations do |t|
      # spreadsheet related metadata (file name, and columns)
      t.string :spreadsheet_name
      t.string :mco_purl
      t.string :catalog_key
      t.string :call_number
      t.boolean :public_domain
      t.date :enters_public_domain
      t.boolean :iu_owns_copyright
      t.boolean :licensed_for_worldwide_access
      t.date :license_expiration_date
      t.string :who_performed_research
      t.string :who_made_open
      t.date :date_made_open
      t.text :comments

      # rmd specific association
      # the associated avalon item, if there is one
      t.integer :avalon_item_id, limit: 8
      # whether a determination was assigned based on if the item was a) found, and b) not already assigned something
      # other than IU Default in RMD
      t.boolean :access_determination_assigned

      # created_at will be when the determination was read in from the spreadsheet
      # updated_at will be when the access determination was set (or not set)
      t.timestamps
    end
  end
end

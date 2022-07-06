class CreateIuAffiliations < ActiveRecord::Migration[4.2]
  def change
    create_table :iu_affiliations do |t|
      t.text :description
      t.timestamps null: false
    end
  end
end

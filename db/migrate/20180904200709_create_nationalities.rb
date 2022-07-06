class CreateNationalities < ActiveRecord::Migration[4.2]
  def change
    create_table :nationalities do |t|
      t.string :nationality
      t.text :description
      t.timestamps null: false
    end
  end
end

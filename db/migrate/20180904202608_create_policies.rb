class CreatePolicies < ActiveRecord::Migration[4.2]
  def change
    create_table :policies do |t|
      t.date :begin_date
      t.date :end_date
      t.timestamps null: false
    end
  end
end

class CreateContracts < ActiveRecord::Migration[4.2]
  def change
    create_table :contracts do |t|
      t.date :contract_date
      t.string :contract_type
      t.integer :select_option
      t.integer :effective_option
      t.date :contract_renewal_date
      t.date :renewal_option_date
      t.boolean :restrictions_imposed
      t.timestamps null: false
    end
  end
end

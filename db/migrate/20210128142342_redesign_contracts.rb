class RedesignContracts < ActiveRecord::Migration[4.2]
  # redesign on contracts requires removal of not only the contracts table, but also
  def up
    drop_table :contracts
    create_table :contracts do |t|
      t.string :date_edtf_text
      t.date :end_date
      t.string :contract_type
      t.text :notes
      t.boolean :perpetual
      t.integer :avalon_item_id
    end
  end

  def down
    drop_table :contracts
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

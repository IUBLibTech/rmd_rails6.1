class AddEntityMetadataToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :entity, :boolean
    add_column :people, :company_name, :text
    add_column :people, :entity_nationality, :text
  end
end

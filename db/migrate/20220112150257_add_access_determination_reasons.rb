class AddAccessDeterminationReasons < ActiveRecord::Migration[4.2]
  def change
    add_column :avalon_items, :reason_ethical_privacy_considerations, :boolean
    add_column :avalon_items, :reason_licensing_restriction, :boolean
    add_column :avalon_items, :reason_feature_film, :boolean

    add_column :avalon_items, :reason_in_copyright, :boolean

    add_column :avalon_items, :reason_public_domain, :boolean
    add_column :avalon_items, :reason_license, :boolean
    add_column :avalon_items, :reason_iu_owned_produced, :boolean

    add_column :avalon_items, :structure_modified, :boolean
  end
end

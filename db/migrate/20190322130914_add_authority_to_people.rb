class AddAuthorityToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :authority_source_url, :text
  end
end

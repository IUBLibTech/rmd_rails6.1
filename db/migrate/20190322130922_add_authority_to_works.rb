class AddAuthorityToWorks < ActiveRecord::Migration[4.2]
  def change
    add_column :works, :authority_source_url, :text
  end
end

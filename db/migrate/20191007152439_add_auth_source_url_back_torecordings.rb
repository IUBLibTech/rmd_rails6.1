class AddAuthSourceUrlBackTorecordings < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :authority_source_url, :text
  end
end

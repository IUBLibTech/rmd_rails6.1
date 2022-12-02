class AddMcoPublishedToAvalonItem < ActiveRecord::Migration[6.1]
  def change
    add_column :avalon_items, :published_in_mco, :boolean
  end
end

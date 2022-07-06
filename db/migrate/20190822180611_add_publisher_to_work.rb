class AddPublisherToWork < ActiveRecord::Migration[4.2]
  def change
    add_column :works, :publisher, :string
  end
end

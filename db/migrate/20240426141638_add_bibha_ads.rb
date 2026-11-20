class AddBibhaAds < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :b_ibha, :boolean
  end
end

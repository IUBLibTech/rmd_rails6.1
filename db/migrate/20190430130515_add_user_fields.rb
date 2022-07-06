class AddUserFields < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :username, :string
    add_column :users, :ignore_ads, :boolean, default: false
    UnitsHelper.units.each do |u|
      add_column :users, (u.underscore.parameterize.to_sym), :boolean
    end
    add_index :users, :username, unique: true
  end
end

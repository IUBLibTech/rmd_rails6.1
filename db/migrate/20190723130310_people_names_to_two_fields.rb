class PeopleNamesToTwoFields < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :first_name, :string
    add_column :people, :last_name, :string
    Person.all.each do |p|
      if p.name.include?(" ")
        names = p.name.split(' ')
        p.update(first_name: names[0], last_name: names[1])
      end
    end
    remove_column :people, :name
  end
end

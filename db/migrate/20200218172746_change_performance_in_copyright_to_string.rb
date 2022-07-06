class ChangePerformanceInCopyrightToString < ActiveRecord::Migration[4.2]
  def up
    add_column :performances, :in_copyright_string, :string
    Performance.all.each do |p|
      p.in_copyright_string = p.in_copyright? ? 'Yes' : p.in_copyright.nil? ? '' : 'No'
      p.save
    end
    remove_column :performances, :in_copyright
    rename_column :performances,:in_copyright_string, :in_copyright
  end

  def down
    rename_column :performances,:in_copyright, :in_copyright_string
    add_column :performances, :in_copyright, :boolean
    Performance.all.eacg do |p|
      p.in_copyright =  p.in_copyright_string == 'Yes' ? true : p.in_copyright_string == 'No' ? false : nil
      p.save
    end
    remove_column :performances, :in_copyright_string
  end
end

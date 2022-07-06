class PersonWorkDatesToEdtf < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :date_of_birth_d, :date
    add_column :people, :date_of_death_d, :date
    add_column :works, :publication_date_d, :date
    add_column :works, :copyright_end_date_d, :date

    Person.all.each do |p|
        begin
          p.date_of_birth_d = Date.edtf(p.date_of_birth.to_s) unless p.date_of_birth.blank?
          p.date_of_death_d = Date.edtf(p.date_of_death.to_s) unless p.date_of_death.blank?
          p.save!
        rescue
          # if we cannot parse to EDTF ignore the date
        end
    end
    Work.all.each do |w|
      begin
        w.publication_date_d = Date.edtf(p.publication_date) unless p.publication_date.blank?
        w.copyright_end_date_d = Date.edtf(p.copyright_end_date) unless p.copyright_end_date.blank?
        w.save!
      rescue
       # if it cannot be parsed to EDTF ignore the date
      end
    end

    change_column :people, :date_of_death, :string
    rename_column :people, :date_of_death, :date_of_death_edtf
    change_column :people, :date_of_birth, :string
    rename_column :people, :date_of_birth, :date_of_birth_edtf

    rename_column :people, :date_of_birth_d, :date_of_birth
    rename_column :people, :date_of_death_d, :date_of_death

    change_column :works, :publication_date, :string
    rename_column :works, :publication_date, :publication_date_edtf
    change_column :works, :copyright_end_date, :string
    rename_column :works, :copyright_end_date, :copyright_end_date_edtf

    rename_column :works,:publication_date_d, :publication_date
    rename_column :works, :copyright_end_date_d, :copyright_end_date
  end
end

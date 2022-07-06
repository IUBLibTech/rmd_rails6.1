class ConvertDatesToYearOnly < ActiveRecord::Migration[4.2]
  def change
    change_column :contracts, :contract_date, :integer
    change_column :contracts, :contract_renewal_date, :integer
    change_column :contracts, :renewal_option_date, :integer

    change_column :people, :date_of_birth, :integer
    change_column :people, :date_of_death, :integer

    change_column :performances, :performance_date, :integer
    change_column :performances, :copyright_end_date, :integer

    change_column :person_iu_affiliations, :begin_date, :integer
    change_column :person_iu_affiliations, :end_date, :integer

    change_column :policies, :begin_date, :integer
    change_column :policies, :begin_date, :integer

    change_column :recordings, :creation_date, :integer
    change_column :recordings, :date_of_first_publication, :integer
    change_column :recordings, :creation_end_date, :integer
    change_column :recordings, :copyright_end_date, :integer

    change_column :works, :publication_Date, :integer
    rename_column :works, :publication_Date, :publication_date
    change_column :works, :copyright_end_date, :integer


  end
end

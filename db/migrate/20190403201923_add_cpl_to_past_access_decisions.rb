class AddCplToPastAccessDecisions < ActiveRecord::Migration[4.2]
  def change
    add_column :past_access_decisions, :copyright_librarian, :boolean, default: false
  end
end

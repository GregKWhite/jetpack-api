class AddSortingToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :order, :integer
  end
end

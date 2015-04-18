class AddDatabasesToComparisons < ActiveRecord::Migration
  def up
  	add_column :comparisons, :database_from, :string
  	add_column :comparisons, :database_to, :string
  end

  def down
	remove_column :comparisons, :database_from
  	remove_column :comparisons, :database_to
  end
end
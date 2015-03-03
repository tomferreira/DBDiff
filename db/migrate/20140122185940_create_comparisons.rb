class CreateComparisons < ActiveRecord::Migration
  def change
    create_table :comparisons do |t|
      t.references :verification_from
      t.references :verification_to
      t.integer :result
      t.text :structures_diff, :limit => 4294967295
      t.text :tables_diff, :limit => 4294967295

      t.timestamps
    end
    add_index :comparisons, :verification_from_id
    add_index :comparisons, :verification_to_id
  end
end

class CreateComparisons < ActiveRecord::Migration
  def change
    create_table :comparisons do |t|
      t.references :verification_from
      t.references :verification_to
      t.integer :result
      t.text :structures_diff
      t.text :tables_diff

      t.timestamps
    end
    add_index :comparisons, :verification_from_id
    add_index :comparisons, :verification_to_id
  end
end

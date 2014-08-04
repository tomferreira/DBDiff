class CreateStructures < ActiveRecord::Migration
  def change
    create_table :structures do |t|
      t.string :dump_filename
      t.string :schema
      t.references :verification

      t.timestamps
    end
    add_index :structures, :verification_id
  end
end

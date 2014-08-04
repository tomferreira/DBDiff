class CreateTableDataVersions < ActiveRecord::Migration
  def change
    create_table :table_data_versions do |t|
      t.string :table
      t.text :data
      t.references :verification

      t.timestamps
    end
    add_index :table_data_versions, :verification_id
  end
end

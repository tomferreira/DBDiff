class CreateVerifications < ActiveRecord::Migration
  def change
    create_table :verifications do |t|
      t.string :database
      t.timestamp :date
      t.integer :duration
      t.boolean :result
      t.text :error_message

      t.timestamps
    end
  end
end

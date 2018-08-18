class CreateKeycards < ActiveRecord::Migration[5.0]
  def change
    create_table :keycards do |t|
      t.boolean :all
      t.integer :floors, array: true, default: []
      t.references :building, foreign_key: true
      t.timestamps
    end
  end
end

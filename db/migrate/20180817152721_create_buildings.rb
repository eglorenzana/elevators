class CreateBuildings < ActiveRecord::Migration[5.0]
  def change
    create_table :buildings do |t|
      t.integer :above_floors, default: 2
      t.integer :below_floors, default: 0
      t.json :floor_naming, default: {}
      t.timestamps
    end
  end
end

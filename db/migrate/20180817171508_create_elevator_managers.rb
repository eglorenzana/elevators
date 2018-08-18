class CreateElevatorManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :elevator_managers do |t|
      t.integer :min
      t.integer :max
      t.integer :default_position, default: 1
      t.integer :current_position, default: 1
      t.references :building, foreign_key: true
      t.references :elevator, foreign_key: true
      t.boolean :emergency, default: false
      t.json :floor_constraints, default: {}

      t.timestamps
    end
  end
end

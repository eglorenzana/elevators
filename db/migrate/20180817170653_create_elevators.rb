class CreateElevators < ActiveRecord::Migration[5.0]
  def change
    create_table :elevators do |t|
      t.integer :max_weight, default: 2240  #2240lb <=> 1 ton
      t.boolean :emergency_stop, default: true

      t.timestamps
    end
  end
end

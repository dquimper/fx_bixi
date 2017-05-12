class CreateStations < ActiveRecord::Migration[5.1]
  def change
    create_table :stations do |t|
      t.string :terminal_id
      t.string :name
      t.integer :nb_bike
      t.integer :nb_empty_dock
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end

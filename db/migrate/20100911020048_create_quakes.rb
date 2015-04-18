class CreateQuakes < ActiveRecord::Migration
  def self.up
    create_table :quakes do |t|
      t.timestamp :strike_time
      t.float :magnitude
      t.float :depth
      t.float :lat
      t.float :lng
      t.string :external_ref

      t.timestamps
    end
    add_index :quakes, :strike_time
    add_index :quakes, :magnitude
    add_index :quakes, :depth
    add_index :quakes, :external_ref
  end

  def self.down
    drop_table :quakes
  end
end

class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :title
      t.string :left
      t.string :right
      t.integer :min_roomsize
      t.integer :max_roomsize
      t.integer :roomtime

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end

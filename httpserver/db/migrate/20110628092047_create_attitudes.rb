class CreateAttitudes < ActiveRecord::Migration
  def self.up
    create_table :attitudes do |t|
      t.references :participation
      t.integer :position
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :attitudes
  end
end

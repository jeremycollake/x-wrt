class CreateBoards < ActiveRecord::Migration
  def self.up
    create_table :boards do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :arch_id, :integer
    end
  end

  def self.down
    drop_table :boards
  end
end

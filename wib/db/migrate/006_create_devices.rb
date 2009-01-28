class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :board_id, :integer
      t.column :ram_size, :integer
      t.column :flash_size, :integer
      t.column :erase_size, :integer
      t.column :cpu_freq, :integer
      t.column :maintainer_id, :integer
    end
  end

  def self.down
    drop_table :devices
  end
end

class CreateFilesystems < ActiveRecord::Migration
  def self.up
    create_table :filesystems do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :overhead_size, :integer
      t.column :compression_ratio, :float
    end
  end

  def self.down
    drop_table :filesystems
  end
end

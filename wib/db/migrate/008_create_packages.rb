class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :size, :integer
      t.column :board_id, :integer
      t.column :os_kernel_id, :integer
      t.column :category_id, :integer
      t.column :maintainer_id, :integer
    end
  end

  def self.down
    drop_table :packages
  end
end

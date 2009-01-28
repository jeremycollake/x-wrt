class AddPackageGroups < ActiveRecord::Migration
  def self.up
    add_column :packages, :group_master, :integer
  end

  def self.down
    remove_column :packages, :group_master
  end
end

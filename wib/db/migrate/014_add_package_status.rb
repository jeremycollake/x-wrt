class AddPackageStatus < ActiveRecord::Migration
  def self.up
    add_column :packages, :status, :string
  end

  def self.down
    remove_column :packages, :status
  end
end

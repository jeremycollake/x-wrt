class AddVendor < ActiveRecord::Migration
  def self.up
    add_column :devices, :vendor, :string
  end

  def self.down
    remove_column :devices, :vendor
  end
end

class CreateHabtmTables < ActiveRecord::Migration
  def self.up
    create_table :devices_os_kernels, :id => false do |t|
      t.column :device_id, :integer
      t.column :os_kernel_id, :integer
    end
    create_table :devices_filesystems, :id => false do |t|
      t.column :device_id, :integer
      t.column :filesystem_id, :integer
    end
    create_table :devices_features, :id => false do |t|
      t.column :device_id, :integer
      t.column :feature_id, :integer
    end
    create_table :devices_packages, :id => false do |t|
      t.column :device_id, :integer
      t.column :package_id, :integer
    end
    create_table :features_packages, :id => false do |t|
      t.column :package_id, :integer
      t.column :feature_id, :integer
    end
    create_table :packages_preselections, :id => false do |t|
      t.column :preselection_id, :integer
      t.column :package_id, :integer
    end
  end

  def self.down
    drop_table :devices_os_kernels
    drop_table :devices_filesystems
    drop_table :devices_features
    drop_table :devices_packages
    drop_table :features_packages
    drop_table :packages_preselections
  end
end

class AddFields < ActiveRecord::Migration
  def self.up
    add_column :devices, :image_type, :string
    add_column :devices, :image_opts, :string
    add_column :packages, :version, :string
    add_column :packages, :release, :integer
  end

  def self.down
    remove_column :devices, :image_type, :string
    remove_column :devices, :image_opts, :string
    remove_column :packages, :version, :string
    remove_column :packages, :release, :integer
  end
end

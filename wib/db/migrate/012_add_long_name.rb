class AddLongName < ActiveRecord::Migration
  def self.up
    add_column :devices, :longname, :string
  end

  def self.down
    remove_column :devices, :longname
  end
end

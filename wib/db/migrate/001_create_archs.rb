class CreateArchs < ActiveRecord::Migration
  def self.up
    create_table :arches do |t|
      t.column :name, :string
      t.column :description, :string
    end
  end

  def self.down
    drop_table :arches
  end
end

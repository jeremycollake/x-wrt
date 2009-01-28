class AddDependencies < ActiveRecord::Migration
  def self.up
    create_table :dependencies, :id => false do |t|
      t.column :dependant, :integer
      t.column :depends_on, :integer
    end
  end

  def self.down
    drop_table :dependencies
  end
end

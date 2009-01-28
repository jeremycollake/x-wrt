class CreatePreselections < ActiveRecord::Migration
  def self.up
    create_table :preselections do |t|
      t.column :name, :string
      t.column :description, :string
    end
  end

  def self.down
    drop_table :preselections
  end
end

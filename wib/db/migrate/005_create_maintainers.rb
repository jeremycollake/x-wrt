class CreateMaintainers < ActiveRecord::Migration
  def self.up
    create_table :maintainers do |t|
      t.column :name, :string
      t.column :email, :string
    end
  end

  def self.down
    drop_table :maintainers
  end
end

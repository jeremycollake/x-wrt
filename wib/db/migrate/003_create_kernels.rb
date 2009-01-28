class CreateKernels < ActiveRecord::Migration
  def self.up
    create_table :os_kernels do |t|
      t.column :name, :string
      t.column :description, :string
    end
  end

  def self.down
    drop_table :os_kernels
  end
end

class Package < ActiveRecord::Base
  belongs_to :category
  belongs_to :maintainer
  has_and_belongs_to_many :boards
  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :dependencies, :class_name => "Package", :join_table => "dependencies", :foreign_key => "dependant", :association_foreign_key => "depends_on"
  has_and_belongs_to_many :dependants, :class_name => "Package", :join_table => "dependencies", :foreign_key => "depends_on", :association_foreign_key => "dependant"
  has_many :preconfigs
end

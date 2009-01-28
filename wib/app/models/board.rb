class Board < ActiveRecord::Base
  has_and_belongs_to_many :filesystems
  has_and_belongs_to_many :packages
  has_many :profiles
end

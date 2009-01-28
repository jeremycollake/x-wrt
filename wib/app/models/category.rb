class Category < ActiveRecord::Base
  has_many :packages
end

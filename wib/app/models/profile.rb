class Profile < ActiveRecord::Base
  belongs_to :boards
  has_and_belongs_to_many :packages, :join_table => 'profiles_packages'
end

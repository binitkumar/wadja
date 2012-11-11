class Country < ActiveRecord::Base
  attr_accessible :iso, :name

  has_many :users
end

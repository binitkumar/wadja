class Status < ActiveRecord::Base
  attr_accessible :name

  has_many :requests_mades

end

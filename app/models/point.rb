class Point < ActiveRecord::Base
  attr_accessible :total, :user_id
  belongs_to :user
end

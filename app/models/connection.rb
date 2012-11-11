class Connection < ActiveRecord::Base
  attr_accessible :network, :secret, :token, :user_id

  belongs_to :user
end

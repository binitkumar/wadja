class RequestsMade < ActiveRecord::Base
  attr_accessible :date_sent, :requested_user_id, :status_id, :type_id, :user_id

  belongs_to :user
  belongs_to :requested_user, :class_name => 'User',:foreign_key => :requested_user_id
  belongs_to :status
  belongs_to :type
end

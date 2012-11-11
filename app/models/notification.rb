class Notification < ActiveRecord::Base
  attr_accessible :contact_id, :message, :request, :user_id
  belongs_to :contact, :class_name => 'User', :foreign_key => :contact_id
  belongs_to :user
end

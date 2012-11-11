class User < ActiveRecord::Base
  attr_accessible :birth_date, :country_id, :email, :email_verified, :name, :password, :username,:photo_url,:gender,:connection_id,:online,:password_salt,:password_hash
  validates_presence_of :birth_date, :country_id, :email, :email_verified, :name, :password, :username,:photo_url,:gender,:connection_id
  validates_uniqueness_of :email, :username

  belongs_to :country
  has_one :point
  has_many :notifications
  has_many :contacts, :class_name => "Notification", :foreign_key => 'contact_id'
  has_many :connections
  has_many :requests_mades
  has_many :requests_received, :class_name => 'RequestsMade',:foreign_key => 'requested_user_id'

  before_save :encrypt_password

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
      self.password = nil
    end
  end

  def self.authenticate_by_email(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def self.authenticate_by_username(username, password)
    user = find_by_username(username)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def get_details
    {
      'id' =>self.id,
      'birth_date' =>self.birth_date.strftime('%d/%m/%Y'),
      'country_iso' =>self.country.iso,
      'email' =>self.email,
      'email_verified' =>self.email_verified,
      'name' =>self.name,
      'username' =>self.username,
      'photo_url' =>self.photo_url,
      'gender' =>self.gender,
      'online' =>self.online ,
      'points' => (self.point.nil? ? 0 : self.point.total ),
      'notifications' => self.notifications.count,
      'requests' => {'ask'=>asks,'give'=>gives },
      'privacy' => 'Yet to be clarified'
    }
  end
  def asks
    self.requests_mades.where(:type_id=>Type.find_by_name('Ask').id).count
  end

  def gives
    self.requests_mades.where(:type_id=>Type.find_by_name('Give').id).count
  end
end

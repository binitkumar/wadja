require 'factory_girl'
FactoryGirl.define do

  factory :user1,:class=>User do |u|
    u.birth_date Date.today
    u.country_id Country.first.id
    u.email 'test100@test.com'
    u.email_verified true
    u.name 'Test user'
    u.password '123456'
    u.username 'Test100User'
    u.photo_url '/assets/test.png'
    u.gender 'Male'
    u.connection_id 1
    u.online false
    u.password_hash nil
    u.password_salt nil
  end

  factory :user2,:class=>User do |u|
    u.birth_date Date.today
    u.country_id Country.first.id
    u.email 'test101@test.com'
    u.email_verified true
    u.name 'Test user'
    u.password '123456'
    u.username 'Test101User'
    u.photo_url '/assets/test.png'
    u.gender 'Male'
    u.connection_id 1
    u.online false
    after_build do |user|
      user.requests_mades << FactoryGirl.build(:requests_made1, :user => user2)
      user.requests_mades << FactoryGirl.build(:requests_made2, :user => user2)
      user.requests_mades << FactoryGirl.build(:requests_made3, :user => user2)

      user.point = FactoryGirl.build(:point,:user=>user2)
      user.notifications << FactoryGirl.build(:first_notification,:user=>user2)
    end
  end

  factory :requests_made1,:class=>RequestsMade do |u|
    u.date_sent Date.today
    u.status_id Status.find_by_name('Pending').id
    u.type_id Type.find_by_name('Ask').id
  end

  factory :requests_made2,:class=>RequestsMade do |u|
    u.date_sent Date.today
    u.status_id Status.find_by_name('Pending').id
    u.type_id Type.find_by_name('Give').id
  end

  factory :requests_made3,:class=>RequestsMade do |u|
    u.date_sent Date.today
    u.status_id Status.find_by_name('Pending').id
    u.type_id Type.find_by_name('Give').id
  end

  factory :first_notification, :class=>Notification do |u|
    u.message'Dummy message'
    u.request 'Yet to be clarified'
  end

  factory :point,:class=>Point do |u|
    u.total 12
  end

end
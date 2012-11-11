require 'spec_helper'
require 'securerandom'

describe Wadja::API do

  include Rack::Test::Methods

  def app
    Wadja::API
  end

  describe "POST /auth/authenticate" do

    before :each do
      @param = { :birth_date=>  Date.today.strftime("%Y-%m-%d"),:country_id => Country.first.id.to_s ,:email=>"test@test.com", :email_verified =>true, :name=> "Test user",:password=> "123456",:username =>"TestUser", :photo_url=> "/assets/test.png", :gender => "Male", :connection_id=> "1", :online=> false }
      @username_password = {:username=>'TestUser', :password=>'123456'}
      @email_password    = {:email=>'test@test.com', :password=>'123456'}
    end

    it "returns true for valid username and password " do
      post "/users", "user"=> @param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']

      post "/auth/authenticate" , @username_password.to_json
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)


      response_json['meta']['code'].should == '000'
      response_json['meta']['error_message'].should == nil
      response_json['data']['id'].should == user_id
    end

    it "returns false for invalid username and password " do
      post "/users", "user"=> @param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']

      @username_password['password'] = '234567'
      post "/auth/authenticate" , @username_password.to_json

      last_response.status.should == 400
      response_json = JSON.parse(last_response.body)
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message'].should == "Invalid username password"
      response_json['data'].should == nil
    end

    it "returns true for valid email and password " do
      post "/users", "user"=> @param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']

      post "/auth/authenticate" , @email_password.to_json

      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      response_json['meta']['code'].should == '000'
      response_json['meta']['error_message'].should == nil
      response_json['data']['id'].should == user_id
    end

    it "returns false for invalid email and password " do
      post "/users", "user"=> @param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']

      @email_password['password'] = '234567'
      post "/auth/authenticate" , @email_password.to_json

      last_response.status.should == 400
      response_json = JSON.parse(last_response.body)
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message'].should == "Invalid email password"
      response_json['data'].should == nil
    end
  end

  describe "GET /users/:id" do

      it "returns invalid id if user id is nil" do
        get "/users"
        last_response.status.should == 404

        response_json = JSON.parse(last_response.body)
        response_json['data'].should == nil
        response_json['meta']['code'].should == '100'
        response_json['meta']['error_message'].should == 'ID parameter not found'
      end

      it "returns nil on user id not available" do
        get "/users/1000"
        last_response.status.should == 404

        response_json = JSON.parse(last_response.body)
        response_json['data'].should == nil
        response_json['meta']['code'].should == '001'
        response_json['meta']['error_message'].should == "User doesn't exist"
      end


      it "returns an user by id" do

        user = FactoryGirl.create(:user1)
        user.requests_mades << FactoryGirl.build(:requests_made1)
        user.requests_mades << FactoryGirl.build(:requests_made2)
        user.requests_mades << FactoryGirl.build(:requests_made3)
        user.point = FactoryGirl.build(:point)
        user.notifications << FactoryGirl.build(:first_notification)

        #todo Please be clarified with request field

        get "/users/#{user.id}"
        last_response.status.should == 200

        response_json = JSON.parse(last_response.body)
        response_json['data']['id'].should == user.id
        response_json['data']['username'].should == 'TestUser'
        response_json['data']['name'].should == 'Test user'
        response_json['data']['email'].should == 'test@test.com'
        response_json['data']['email_verified'].should == true
        response_json['data']['country_iso'].should == user.country.iso
        response_json['data']['birth_date'].should == user.birth_date.strftime("%d/%m/%Y")
        response_json['data']['online'].should == user.online
        response_json['data']['photo_url'].should == "/assets/test.png"
        response_json['data']['gender'].should == "Male"
        response_json['data']['points'].should == 12
        response_json['data']['requests']['ask'].should == 1
        response_json['data']['requests']['give'].should == 2

        #todo: Take clarification for privacy
        puts "Take clarification for privacy"
        response_json['data']['privacy'].should == 'Yet to be clarified'

        response_json['data']['notifications'].should == 1
        response_json['meta']['code'].should == '000'
        response_json['meta']['error_message'].should == nil
      end

      it "returns invalid integer for alphanumeric id" do
        get "/users/1ab"
        last_response.status.should == 404

        response_json = JSON.parse(last_response.body)
        response_json['data'].should == nil
        response_json['meta']['error_message'].should == 'Invalid id parameter'
        response_json['meta']['code'].should == '100'

      end
  end





  describe "POST /users" do
    before :each do
      @param = { :birth_date=>  Date.today.strftime("%Y-%m-%d"),:country_id => Country.first.id.to_s ,:email=>"test@test.com", :email_verified =>true, :name=> "Test user",:password=> "123456",:username =>"TestUser", :photo_url=> "/assets/test.png", :gender => "Male", :connection_id=> "1", :online=> false }
    end
    it "creates a new user with valid parameters" do

      post "/users", "user"=> @param
      last_response.status.should == 200

      response_json = JSON.parse(last_response.body)
      response_json['data']['userid'].should_not == nil
      response_json['data']['username'].should == 'TestUser'
      response_json['meta']['code'].should == '000'
      response_json['meta']['error_message'].should == nil
    end

    it "does not creates a new user with missing birth data parameters" do
      @param.delete(:birth_date)
      #param = { :country_id => Country.first.id.to_s ,:email=>"test@test.com", :email_verified =>true, :name=> "Test user",:password=> "123456",:username =>"TestUser", :photo_url=> "/assets/test.png", :gender => "Male", :connection_id=> "1", :online=> false }
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['birth_date'].should == ["can't be blank"]
    end

    it "does not creates a new user with missing country parameters" do
      @param.delete(:country_id)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['country_id'].should == ["can't be blank"]
    end

    it "does not creates a new user with missing email parameters" do
      @param.delete(:email)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['email'].should == ["can't be blank"]
    end

    it "does not creates a new user with missing email verified parameters" do
      @param.delete(:email_verified)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['email_verified'].should == ["can't be blank"]
    end
    it "does not creates a new user with missing name parameters" do
      @param.delete(:name)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['name'].should == ["can't be blank"]
    end
    it "does not creates a new user with missing password parameters" do
      @param.delete(:password)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['password'].should == ["can't be blank"]
    end
    it "does not creates a new user with missing username parameters" do
      @param.delete(:username)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['username'].should == ["can't be blank"]
    end
    it "does not creates a new user with missing photo url parameters" do
      @param.delete(:photo_url)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['photo_url'].should == ["can't be blank"]
    end
    it "does not creates a new user with missing gender parameters" do
      @param.delete(:gender)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['gender'].should == ["can't be blank"]
    end
    it "does not creates a new user with missing connection id parameters" do
      @param.delete(:connection_id)
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message']['connection_id'].should == ["can't be blank"]
    end

    it "does not creates a new user with duplicate email parameters" do
      post "/users", "user"=> @param
      last_response.status.should == 200
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '001'
      response_json['meta']['error_message']['email'].should == ["has already been taken"]
      response_json['meta']['error_message']['username'].should == ["has already been taken"]
    end

    it "does not creates a new user with duplicate username parameters" do
      post "/users", "user"=> @param
      last_response.status.should == 200
      @param['email'] = 'test1@test.com'
      post "/users", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '002'
      response_json['meta']['error_message']['username'].should == ["has already been taken"]
    end
  end

  describe "PUT /users/:id" do
    before :each do
      @param = { :birth_date=>  Date.today.strftime("%Y-%m-%d"),:country_id => Country.first.id.to_s ,:email=>"test@test.com", :email_verified =>true, :name=> "Test user",:password=> "123456",:username =>"TestUser", :photo_url=> "/assets/test.png", :gender => "Male", :connection_id=> "1", :online=> false }
    end

    it "upates user with valid parameters" do
      post "/users", "user"=>@param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']
      @param['username'] = "Test1User"
      put "/users/#{user_id}",:user=>@param
      last_response.status.should == 200

      get "/users/#{user_id}"
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      response_json['data']['username'].should == 'Test1User'
    end

    it "does not update a user with duplicate email parameters" do
      post "/users", "user"=> @param
      last_response.status.should == 200


      @param['email'] = 'test1@test.com'
      @param['username'] = 'Test1User'
      post "/users", "user"=>@param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']

      @param["email"] = 'test@test.com'
      @param['username'] = 'Test2User'
      put "/users/#{user_id}", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '001'
      response_json['meta']['error_message']['email'].should == ["has already been taken"]
    end

    it "does not creates a new user with duplicate username parameters" do
      post "/users", "user"=> @param
      last_response.status.should == 200


      @param['email'] = 'test1@test.com'
      @param['username'] = 'Test1User'
      post "/users", "user"=>@param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']

      @param["email"] = 'test1@test.com'
      @param['username'] = 'TestUser'
      put "/users/#{user_id}", "user"=> @param
      last_response.status.should == 400

      response_json = JSON.parse(last_response.body)
      response_json['data'].should == nil
      response_json['meta']['code'].should == '002'
      response_json['meta']['error_message']['username'].should == ["has already been taken"]
    end

  end

  describe "get /users/checkusernameavailability/:username" do

    before :each do
      @param = { :birth_date=>  Date.today.strftime("%Y-%m-%d"),:country_id => Country.first.id.to_s ,:email=>"test@test.com", :email_verified =>true, :name=> "Test user",:password=> "123456",:username =>"TestUser", :photo_url=> "/assets/test.png", :gender => "Male", :connection_id=> "1", :online=> false }
    end

    it 'returns false for username already existing in the database' do
      post "/users", "user"=> @param
      last_response.status.should == 200

      get '/users/checkusernameavailability/TestUser'
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      response_json['data']['available'].should == false
    end

    it 'returns true for username which is not existing in the database' do
      post "/users", "user"=> @param
      last_response.status.should == 200

      get '/users/checkusernameavailability/Test1User'
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      response_json['data']['available'].should == true
    end

  end

  describe "delete /users/:id" do

    before :each do
      @param = { :birth_date=>  Date.today.strftime("%Y-%m-%d"),:country_id => Country.first.id.to_s ,:email=>"test@test.com", :email_verified =>true, :name=> "Test user",:password=> "123456",:username =>"TestUser", :photo_url=> "/assets/test.png", :gender => "Male", :connection_id=> "1", :online=> false }
    end

    it "deletes user from database on valid user id" do
      post "/users", "user"=> @param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']
      delete "/users/#{user_id}"
      response_json = JSON.parse(last_response.body)
      last_response.status.should == 200
      response_json['meta']['code'].should == '000'
      response_json['meta']['error_message'].should == nil
      response_json['data'].should == nil
    end

    it "gives invalid user id message if user id is invalid" do
      post "/users", "user"=> @param
      last_response.status.should == 200
      response_json = JSON.parse(last_response.body)
      user_id = response_json['data']['userid']

      delete "/users/1000"
      response_json = JSON.parse(last_response.body)
      last_response.status.should == 400
      response_json['meta']['code'].should == '100'
      response_json['meta']['error_message'].should == "User doesn't exists"
      response_json['data'].should == nil
    end

  end

end
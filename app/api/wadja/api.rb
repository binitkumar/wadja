require 'grape'
require 'securerandom'

module Wadja

  class API < Grape::API
    format :json
    version 'v1', :using => :path

    resource :auth do
      post "authenticate" do
        authentication_details = nil
        response_hash = Hash.new
        response_hash['meta']= Hash.new
        response_hash['data']= Hash.new

        if params[:email]
          authentication_details = User.authenticate_by_email(params[:email],params[:password])
        elsif params[:username]
          authentication_details = User.authenticate_by_username(params[:username],params[:password])
        end

        if authentication_details
          status 200
          response_hash['meta']['code'] = '000'
          response_hash['meta']['error_message'] = nil
          response_hash['data'] = authentication_details.get_details
          token = SecureRandom.urlsafe_base64(16)

          user = User.find_by_username params[:username] if params[:username]
          user = User.find_by_email params[:email] if params[:email]
          user.update_attribute(:authentication_token,token)

          response_hash['data']['authentication_token'] = token
        else
          status 400
          response_hash['meta']['code'] = '100'
          response_hash['meta']['error_message'] = "Invalid username password" if params[:username]
          response_hash['meta']['error_message'] = "Invalid email password" if params[:email]
          response_hash['data'] = nil
        end

        if params[:email].nil? && params[:username].nil?
          response_hash['meta']['code'] = '100'
          response_hash['meta']['error_message'] = "Username & Email unavailable in parameter "
          response_hash['data'] = nil
          status 400
        end
        response_hash
      end

      get ":id/killsession/:authentication_token" do
        response_hash = Hash.new
        response_hash['meta']= Hash.new
        response_hash['data']= Hash.new

        user = User.find_by_id(params[:id])
        orig_user= User.find_by_authentication_token(params[:authentication_token])
        if user == orig_user
          user.update_attribute(:authentication_token,nil)
          response_hash['meta']['code'] = '000'
          response_hash['data'] = 'Logout successful'
          response_hash['meta']['error_message'] = nil
        else
          response_hash['meta']['code'] = '100'
          response_hash['meta']['error_message'] = "Invalid user credentials"
          response_hash['data'] = nil
          status 400
        end
        response_hash
      end
    end


    resource :users do

      post do
        response_hash = Hash.new
        response_hash['meta']= Hash.new
        response_hash['data']= Hash.new
        begin
          user = User.new(params[:user])
		      if user.valid?
            user.save
		        response_hash['data']['userid']= user.id
            response_hash['data']['username']=user.username
            response_hash['meta']['code'] = '000'
            status 200
		      else
            response_hash['meta']['error_message'] = user.errors
		        response_hash['data']= nil
            status 400
            response_hash['meta']['code'] = '100'
            response_hash['meta']['code'] = '002' if user.errors['username'] == ["has already been taken"]
            response_hash['meta']['code'] = '001' if user.errors['email'] == ["has already been taken"]
          end
        rescue
          response_hash['data'] = nil
          response_hash['meta']['code'] = "101"
          response_hash['meta']['error_message'] = 'Internal server error'
          status 404
        end
		    response_hash
      end
      
      get :authentication_token do
        response = Hash.new
        response['meta'] = Hash.new
        response['data'] = nil
        response['meta']['error_message'] = 'ID parameter not found'
        response['meta']['code'] = '100'
        status 404
        response
      end
      
      get ':id/get/:authentication_token' do
        @response = Hash.new
        @response['meta'] = Hash.new

        begin
          if params[:id].to_i.to_s == params[:id].to_s
            user = User.where(:id=>params[:id].to_i).first
            if user.nil?
              ResponseHandler.set_invalid_response(@response,'001')
              @response['meta']['error_message'] = "User doesn't exist"
              status 404
            else
              @response['data'] = user.get_details
              @response['meta']['code'] = '000'
              status 200
            end
          else
            ResponseHandler.set_invalid_response @response
            @response['meta']['code'] = '100'
            @response['meta']['error_message'] = 'Invalid id parameter'
            @response['meta']['data'] = nil
            status 404
          end
        rescue
          ResponseHandler.set_invalid_response @response
          @response['meta']['error_message'] = "Internal server error"
          status 404
        end
        @response
      end

      put ':id/update/:authentication_token' do
        response_hash = Hash.new
        response_hash['meta']= Hash.new
        response_hash['data']= Hash.new
        begin
          user = User.where(:id=>params[:id]).first
          orig_user = User.where(:authentication_token=>params[:authentication_token]).first

          if user == orig_user
            params[:user].each do |key,value|
              user[key] = value
            end

            if user.valid?
              response_hash['data']['userid']= user.id
              response_hash['data']['username']=user.username
              response_hash['meta']['code'] = '000'
              user.save
              status 200
            else
              response_hash['meta']['error_message'] = user.errors
              response_hash['data']= nil
              status 400
              response_hash['meta']['code'] = '100'
              response_hash['meta']['code'] = '002' if user.errors['username'] == ["has already been taken"]
              response_hash['meta']['code'] = '001' if user.errors['email'] == ["has already been taken"]
            end
          else
            response_hash['data']= nil
            status 401
            response_hash['meta']['code'] = "100"
            response_hash['meta']['error_message'] = "Invalid user credentials"
          end
        rescue
          response_hash['data'] = nil
          response_hash['meta']['code'] = "101"
          response_hash['meta']['error_message'] = 'Internal server error'
          status 404
        end
        response_hash

      end

      get "checkusernameavailability/:username" do
        response_hash = Hash.new
        response_hash['meta']= Hash.new
        response_hash['data']= Hash.new
        begin
          user = User.where(:username=>params[:username]).first
          if user
            response_hash['data']['available'] = false
            response_hash['meta']['code'] = "002"
            response_hash['meta']['error_message'] = 'has already been taken'
            status 200
          else
            response_hash['data']['available'] = true
            response_hash['meta']['code'] = "000"
            response_hash['meta']['error_message'] = nil
            status 200
          end
        rescue
          response_hash['data'] = nil
          response_hash['meta']['code'] = "100"
          response_hash['meta']['error_message'] = 'Internal server error'
          status 404
        end
        response_hash
      end

      delete ":id" do
        response_hash = Hash.new
        response_hash['meta']= Hash.new
        response_hash['data']= nil
        begin
          user = User.where(:id=>params[:id]).first
          if user
            user.destroy
            response_hash['meta']['code'] = '000'
            response_hash['meta']['error_message'] = nil
            status 200
          else
            response_hash['meta']['code'] = '100'
            response_hash['meta']['error_message'] = "User doesn't exists"
            status 400
          end
        rescue
          response_hash['meta']['code'] = '100'
          response_hash['meta']['error_message'] = "Internal server error"
          status 404
        end
        response_hash
      end
    end
  end

  class ResponseHandler
    def self.set_invalid_response(response,code='100')
      response['meta']['code'] = code
      response['data'] = nil
    end
  end
end
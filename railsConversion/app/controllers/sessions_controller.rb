class SessionsController < ApplicationController
  def new
  	# @session=Session.new
  end

  def create
  		user=User.find_by_email(params[:email])
  		if user && user.authenticate(params[:password])
  			session[:user_id] = user.id
  			redirect_to root_url, notice: "Success"
  		else
  			flash.now.alert = "Email or password invalid"
  			render "new"
  		end
  end
  def destroy
  	session{:user_id} = nil
  	redirect_to root_url, notice: "You have logged out"


  end
end

class User < ActiveRecord::Base
	has_secure_password
	# attr_accessible :email,:password, :password_confirmation
	validates_uniqueness_of :email
	def new
	  @user = User.new
	end

	def create
	  @user = User.new(params[:user])
	  if @user.save
	    session[:user_id] = @user.id
	    redirect_to root_url, notice: "Thank you for signing up!"
	  else
	    render "new"
	  end
	end




	
	def generate_auth_token
	  payload = { user_id: self.id }
	  AuthToken.encode(payload)
	end

end

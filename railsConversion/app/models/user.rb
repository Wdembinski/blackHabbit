class User < ActiveRecord::Base
	include Authentication
	has_secure_password
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, length: { maximum: 255 },uniqueness: true
	validates :password, length: {maximum: 250, minimum:5}
	




	def generate_auth_token
	  payload = { user_id: self.id }
	  AuthToken.encode(payload)
	end


	def find_by_credentials
		
	end

end
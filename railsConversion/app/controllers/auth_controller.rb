class AuthController < ApplicationController
	skip_before_action :authenticate_request, only:[:authenticate]# this will be implemented later
 




  def authenticate
    user = User.find_by(params[:username], params[:password]) # you'll need to implement this
    if user
      render json: { auth_token: user.generate_auth_token }
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = user.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :password,:password_confirmation)
    end


    
end

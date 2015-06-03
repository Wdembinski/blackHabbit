class AuthController < ApplicationController
	skip_before_action :set_current_user,:authenticate_request, only:[:login,:register]# this will be implemented later
  

  def login
    unix_time=Time.now.to_f * 1000 #best way to pass date to client imo
    user=User.find_by(email: params[:email])
    if user and user.authenticate(params[:password])
      user.update last_logged_in: Time.now
      cookies.encrypted[:secure_session]="#{Time.now.to_i}--#{user.id}--#{user.email}"
      cookies[:user]="{\"email\":\"#{user.email}\",\"logged_in_time\":\"#{unix_time}\"}"
      render json: "{\"status\":\"confirmed\"}"
    else
      render json: "{\"status':\"denied\"}"
    end
  end

  def logout
    cookies.delete[:secure_session]
    cookies.delete[:u_email] 
    cookies.delete[:logged_in_time]
    flash[:top_msg] = "Session terminated"
    redirect_to root_url
  end

  def authenticate
    # puts cookies.encrypted[:secure_session] #get angular talking to server
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

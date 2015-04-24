class ApplicationController < ActionController::Base
  include Authentication
  skip_before_action :verify_authenticity_token
  before_action :set_current_user, :authenticate_request
  # protect_from_forgery with: :exception
  # after_filter :set_csrf_cookie_for_ng #maybe update cookie time

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  rescue_from NotAuthenticatedError do
    # render json: { error: 'Not Authorized' }, status: :unauthorized
  end

  rescue_from AuthenticationTimeoutError do
    # render json: { error: 'Auth token is expired' }, status: 419 # unofficial timeout status code
  end

  private

  helper_method :current_user
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  # Based on the user_id inside the token payload, find the user.
  def set_current_user
    if decoded_auth_token
      puts decoded_auth_token
      @current_user ||= User.find(decoded_auth_token.split("--")[1])
    end
  end

  # Check to make sure the current user was set and the token is not expired
  def authenticate_request
    if auth_token_expired?
      fail AuthenticationTimeoutError
    elsif !@current_user
      fail NotAuthenticatedError
    end
  end

  def decoded_auth_token
    @decoded_auth_token ||= cookies.encrypted['secure_session']
    # @decoded_auth_token ||= AuthToken.decode(http_auth_header_content)
  end

  def auth_token_expired?
    puts cookies.encrypted["secure_session"]
    if !cookies.encrypted["secure_session"] || (Time.now - Time.at(cookies.encrypted["secure_session"].split("--")[0].to_i)) > 1.minutes
      flash[:login_err] = "Session expired"
      redirect_to '/users/new'
    else
      flash[:login_err] = "Welcome!"
      render "searches/new" 
    end
  end

  # JWT's are stored in the Authorization header using this format:
  # Bearer somerandomstring.encoded-payload.NotAuthenticatedError
  def http_auth_header_content
    return @http_auth_header_content if defined? @http_auth_header_content
    @http_auth_header_content = begin
      if request.headers['Authorization'].present?
        request.headers['Authorization'].split(' ').last
      else
        nil
      end
    end
  end
end

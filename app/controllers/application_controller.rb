class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  private
  def authenticate
    authenticate_or_request_with_http_token do |token, opts|
      @current_user = Account.find_by(auth_token: token)
    end
  end
end

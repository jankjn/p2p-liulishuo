class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  private
  def authenticate
    authenticate_or_request_with_http_token do |token, opts|
      @current_user = Account.find_by(auth_token: token)
    end
  end

  def miss_params(*keys)
    missing_keys = keys.select { |k| params[k].nil? }
    missing_keys.any? and render json: { error: "param #{missing_keys} is not provided" }, status: 400
  end
end

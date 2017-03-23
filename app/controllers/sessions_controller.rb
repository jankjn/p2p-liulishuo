class SessionsController < ApplicationController
  def create
    return if miss_params(:username, :password)
    account = Account.find_by(username: login_params[:username])
    if account&.authenticate(login_params[:password])
      account.set_auth_token
      render json: { token: account.auth_token, id: account.id }
    else
      render json: { error: 'username or password is invalid' }, status: 401
    end
  end

  private
  def login_params
    params.permit(:username, :password)
  end
end

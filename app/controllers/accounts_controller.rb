class AccountsController < ApplicationController
  before_action :authenticate, except: :create

  def index
    render json: Account.select(:id, :username, :deposit, :created_at, :updated_at)
  end

  def show
    account = Account.find_by(id: params[:id])
    if account.nil?
      render json: { error: 'account not found' }, status: 404
    elsif params[:with].nil?
      render json: account.debt_status
    else
      other_account = Account.find_by(id: params[:with])
      if other_account
        render json: account.debt_status_with(other_account)
      else
        render json: { error: 'second account is invalid' }, status: 404
      end
    end
  end

  def create
    return if miss_params(:username, :password, :deposit)
    account = Account.create(create_params)
    if account.valid?
      render json: account
    else
      render json: account.errors, status: 400
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { error: 'username already used' }
  end

  private
  def create_params
    params.permit(:username, :password, :deposit)
  end
end

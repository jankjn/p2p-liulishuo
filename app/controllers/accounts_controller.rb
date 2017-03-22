class AccountsController < ApplicationController
  before_action :authenticate, except: :create

  def index
    render json: Account.select(:id, :username, :deposit, :created_at, :updated_at)
  end

  def show
    account = Account.find(params[:id])
    other_account = Account.find_by(id: params[:with])
    debt_status = other_account ? account.debt_status_with(other_account) : account.debt_status
    render json: debt_status
  end

  def create
    account = Account.create!(create_params)
    render json: account
  end

  private
  def create_params
    params.permit(:username, :password, :deposit)
  end
end

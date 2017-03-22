class AccountsController < ApplicationController

  def index
    render json: Account.all
  end

  def show
    account = Account.find(params[:id])
    other_account = Account.find_by(id: params[:with])
    debt_status = other_account ? account.debt_status_with(other_account) : account.debt_status
    render json: debt_status
  end
end

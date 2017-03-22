require 'actions/pay_back_action'

class PayBacksController < ApplicationController
  before_action :authenticate

  def index
    render json: PayBack.all
  end

  def show
    render json: PayBack.find(params[:id])
  end

  def create
    lender = Account.find(create_params[:lender_id])
    borrower = Account.find(create_params[:borrower_id])
    if @current_user == borrower
      pay_back = PayBackAction.exec(lender: lender, borrower: borrower, amount: create_params[:amount])
      render json: pay_back
    else
      render json: { error: 'only borrower can confirm a loan' }, status: 403
    end
  rescue PayBackOverflowError
    render json: { error: 'can not pay back more than lends' }, status: 400
  rescue PayBackUnderflowError
    render json: { error: 'borrower can not afford the pay back' }, status: 400
  end

  private
  def create_params
    params.permit(:lender_id, :borrower_id, :amount)
  end
end

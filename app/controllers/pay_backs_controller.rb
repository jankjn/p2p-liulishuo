require_dependency 'actions/pay_back_action'

class PayBacksController < ApplicationController
  before_action :authenticate

  def index
    render json: PayBack.all
  end

  def show
    pay_back = PayBack.find_by(id: params[:id])
    if pay_back
      render json: pay_back
    else
      render json: { error: 'pay back not found' }, status: 404
    end
  end

  def create
    return if miss_params(:lender_id, :borrower_id, :amount)

    lender = Account.find(create_params[:lender_id])
    borrower = Account.find(create_params[:borrower_id])
    pay_back = PayBack.new(lender: lender, borrower: borrower, amount: params[:amount])

    if lender.nil?
      render json: { error: 'lender is not found' }, status: 404
    elsif borrower.nil?
      render json: { error: 'borrower is not found' }, status: 404
    elsif pay_back.invalid?
      render json: pay_back.errors, status: 400
    elsif @current_user == borrower
      PayBackAction.exec(pay_back)
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

require_dependency 'actions/confirm_loan_action'

class LoansController < ApplicationController
  before_action :authenticate

  def index
    render json: Loan.all
  end

  def show
    loan = Loan.find_by(id: params[:id])
    if loan
      render json: loan
    else
      render json: { error: 'loan not found' }, status: 404
    end
  end

  def create
    return if miss_params(:lender_id, :borrower_id, :amount)

    lender = Account.find_by(id: create_params[:lender_id])
    borrower = Account.find_by(id: create_params[:borrower_id])
    loan = Loan.new(lender: lender, borrower: borrower, amount: create_params[:amount])

    if lender.nil?
      render json: { error: 'lender is not found' }, status: 404
    elsif borrower.nil?
      render json: { error: 'borrower is not found' }, status: 404
    elsif loan.invalid?
      render json: loan.errors, status: 400
    elsif loan.overflow?
      render json: { error: 'money not enough to lend' }, status: 400
    else
      loan.save! and render json: loan
    end
  end

  def confirm
    loan = Loan.find_by(id: params[:id])

    if loan.nil?
      render json: { error: 'loan is invalid' }, status: 404
    elsif @current_user == loan.lender
      ConfirmLoanAction.exec(loan)
      render json: loan
    else
      render json: { error: 'only lender can confirm a loan' }, status: 403
    end
  rescue LoanOverflowError
    render json: { error: 'money not enough to lend' }, status: 400
  end

  private
  def create_params
    params.permit(:lender_id, :borrower_id, :amount)
  end
end

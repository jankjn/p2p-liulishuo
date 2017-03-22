require 'actions/confirm_loan_action'

class LoansController < ApplicationController

  def index
    render json: Loan.all
  end

  def show
    render json: Loan.find(params[:id])
  end

  def create
    lender = Account.find(create_params[:lender_id])
    borrower = Account.find(create_params[:borrower_id])
    loan = Loan.new(lender: lender, borrower: borrower, amount: create_params[:amount])

    if loan.overflow?
      render json: { error: 'money not enough to lend' }, status: 400
    else
      loan.save!
      render json: loan
    end
  end

  def confirm
    loan = Loan.find(params[:id])

    if current_account_is_lender
      ConfirmLoanAction.exec(loan)
      render json: loan
    else
      render json: { error: 'only lender can confirm a loan' }, status: 403
    end
  rescue
    render json: { error: 'money not enough to lend' }, status: 400
  end

  private
  def create_params
    params.permit(:lender_id, :borrower_id, :amount)
  end

  def current_account_is_lender
    true #TODO
  end
end

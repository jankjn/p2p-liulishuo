require 'rails_helper'
require 'actions/confirm_loan_action'

RSpec.describe Loan, type: :model do
  let(:lender) { Account.create(deposit: 100) }
  let(:borrower) { Account.create(deposit: 100) }

  context 'loan 50 from 100' do
    let(:loan) { Loan.create(lender: lender, borrower: borrower, amount: 50) }

    it 'is not overflow' do
      expect(loan).to_not be_overflow
    end

    it 'is not confirmed by default' do
      expect(loan).to_not be_confirmed
    end

    it 'transfer money when confirmed' do
      expect {
        ConfirmLoanAction.exec(loan)
      }.to change { lender.deposit }.from(100).to(50)
        .and change { lender.lends }.from(0).to(50)
        .and change { lender.lends_to(borrower) }.from(0).to(50)
        .and change { borrower.deposit }.from(100).to(150)
        .and change { borrower.borrows }.from(0).to(50)
        .and change { borrower.borrows_from(lender) }.from(0).to(50)
      expect(loan).to be_confirmed
    end
  end

  context 'loan 150 from 100' do
    let(:loan) { Loan.create(lender: lender, borrower: borrower, amount: 150) }

    it 'is overflow' do
      expect(loan).to be_overflow
    end

    it 'can not transfer money' do
      expect { ConfirmLoanAction.exec(loan) }.to raise_error(LoanOverflowError)
        .and change { lender.deposit }.by(0)
        .and change { borrower.deposit }.by(0)
      expect(loan).to_not be_confirmed
    end
  end

end

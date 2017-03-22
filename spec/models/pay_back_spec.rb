require 'rails_helper'
require 'actions/confirm_loan_action'
require 'actions/pay_back_action'

RSpec.describe PayBack, type: :model do
  before(:all) do
    @lender = Account.create(username: 'lender', password: 'lender', deposit: 100)
    @borrower = Account.create(username: 'borrower', password: 'borrower', deposit: 0)
    @loan = Loan.create(lender: @lender, borrower: @borrower, amount: 50)
    ConfirmLoanAction.exec(@loan)
  end
  after(:all) do
    Loan.all.each &:destroy
    Account.all.each &:destroy
  end
  let(:lender) { @lender }
  let(:borrower) { @borrower }
  let(:loan) { @loan }

  context 'pay back 50 to 50' do
    it 'can pay back' do
      expect {
        PayBackAction.exec(lender: lender, borrower: borrower, amount: 50)
      }.to change { lender.deposit }.from(50).to(100)
        .and change { lender.lends }.from(50).to(0)
        .and change { lender.lends_to(borrower) }.from(50).to(0)
        .and change { borrower.deposit }.from(50).to(0)
        .and change { borrower.borrows }.from(50).to(0)
        .and change { borrower.borrows_from(lender) }.from(50).to(0)
    end

    it 'can not pay back without enough deposit' do
      expect {
        PayBackAction.exec(lender: lender, borrower: borrower, amount: 50)
      }.to raise_error(PayBackUnderflowError)
        .and change { lender.deposit }.by(0)
        .and change { borrower.deposit }.by(0)
    end
  end

  context 'pay back 100 to 50' do
    it 'can not pay back' do
      expect {
        PayBackAction.exec(lender: lender, borrower: borrower, amount: 100)
      }.to raise_error(PayBackOverflowError)
        .and change { lender.deposit }.by(0)
        .and change { borrower.deposit }.by(0)
    end
  end
end

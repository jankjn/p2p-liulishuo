require 'rails_helper'

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
      loan.confirm!
      expect(loan).to be_confirmed
      expect(lender.deposit).to eq(100 - 50)
      expect(borrower.deposit).to eq(100 + 50)
    end
  end

  context 'loan 150 from 100' do
    let(:loan) { Loan.create(lender: lender, borrower: borrower, amount: 150) }

    it 'is overflow' do
      expect(loan).to be_overflow
    end

    it 'can not transfer money' do
      expect { loan.confirm! }.to raise_error(LoanOverflowError)
      expect(loan).to_not be_confirmed
      expect(lender.deposit).to eq(100)
      expect(borrower.deposit).to eq(100)
    end
  end

end

class Loan < ApplicationRecord
  belongs_to :borrower, class_name: 'Account'
  belongs_to :lender, class_name: 'Account'

  validates :amount, numericality: { greater_than: 0 }

  def confirm!
    transaction do
      raise LoanOverflowError if overflow?
      lender.take_out(amount)
      borrower.put_in(amount)
      update!(confirmed: true)
    end
  end

  def overflow?
    lender.deposit < self.amount
  end
end

class LoanOverflowError < RuntimeError; end

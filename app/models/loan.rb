class Loan < ApplicationRecord
  belongs_to :borrower, class_name: 'Account'
  belongs_to :lender, class_name: 'Account'

  validates :amount, numericality: { greater_than: 0 }

  def overflow?
    lender.deposit < self.amount
  end
end

class LoanOverflowError < RuntimeError; end

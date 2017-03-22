class PayBack < ApplicationRecord
  belongs_to :borrower, class_name: 'Account'
  belongs_to :lender, class_name: 'Account'

  def overflow?
    borrower.borrows_from(lender) < self.amount
  end

  def underflow?
    borrower.deposit < self.amount
  end
end

class PayBackOverflowError < RuntimeError; end
class PayBackUnderflowError < RuntimeError; end

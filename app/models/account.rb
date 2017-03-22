class Account < ApplicationRecord

  validates :deposit, numericality: { greater_than_or_equal_to: 0 }

  def borrows
    transaction do
      Loan.where(borrower: self).sum(:amount) - PayBack.where(borrower: self).sum(:amount)
    end
  end

  def lends
    transaction do
      Loan.where(lender: self).sum(:amount) - PayBack.where(lender: self).sum(:amount)
    end
  end

  def borrows_from(lender)
    transaction do
      Loan.where(borrower: self, lender: lender).sum(:amount) - PayBack.where(borrower: self, lender: lender).sum(:amount)
    end
  end

  def lends_to(borrower)
    transaction do
      Loan.where(borrower: borrower, lender: self).sum(:amount) - PayBack.where(borrower: borrower, lender: self).sum(:amount)
    end
  end

  def take_out(amount)
    update!(deposit: deposit - amount)
  end

  def put_in(amount)
    update!(deposit: deposit + amount)
  end
end

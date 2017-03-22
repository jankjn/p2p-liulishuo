class Account < ApplicationRecord

  validates :deposit, numericality: { greater_than_or_equal_to: 0 }

  def debt_status
    { borrows: borrows, lends: lends, deposit: deposit }
  end

  def debt_status_with(account)
    {
      borrows: borrows_from(account),
      lends: lends_to(account),
    }
  end

  def borrows
    transaction do
      Loan.where(borrower: self, confirmed: true).sum(:amount) - PayBack.where(borrower: self).sum(:amount)
    end
  end

  def lends
    transaction do
      Loan.where(lender: self, confirmed: true).sum(:amount) - PayBack.where(lender: self).sum(:amount)
    end
  end

  def borrows_from(lender)
    transaction do
      Loan.where(borrower: self, lender: lender, confirmed: true).sum(:amount) - PayBack.where(borrower: self, lender: lender).sum(:amount)
    end
  end

  def lends_to(borrower)
    transaction do
      Loan.where(borrower: borrower, lender: self, confirmed: true).sum(:amount) - PayBack.where(borrower: borrower, lender: self).sum(:amount)
    end
  end

  def take_out(amount)
    update!(deposit: deposit - amount)
  end

  def put_in(amount)
    update!(deposit: deposit + amount)
  end
end

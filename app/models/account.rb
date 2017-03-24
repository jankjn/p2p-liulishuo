class Account < ApplicationRecord

  has_secure_password

  validates :deposit, numericality: { greater_than_or_equal_to: 0 }
  validates :username, presence: true, uniqueness: true

  after_create_commit do
    set_auth_token if auth_token.nil?
  end

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
      Loan.where(borrower: self, confirmed: true).sum(:amount) -
        PayBack.where(borrower: self).sum(:amount)
    end
  end

  def lends
    transaction do
      Loan.where(lender: self, confirmed: true).sum(:amount) -
        PayBack.where(lender: self).sum(:amount)
    end
  end

  def borrows_from(lender)
    transaction do
      Loan.where(borrower: self, lender: lender, confirmed: true).sum(:amount) -
        PayBack.where(borrower: self, lender: lender).sum(:amount)
    end
  end

  def lends_to(borrower)
    transaction do
      Loan.where(borrower: borrower, lender: self, confirmed: true).sum(:amount) -
        PayBack.where(borrower: borrower, lender: self).sum(:amount)
    end
  end

  def take_out(amount)
    update!(deposit: deposit - amount)
  end

  def put_in(amount)
    update!(deposit: deposit + amount)
  end

  def set_auth_token
    update!(auth_token: generate_token)
  end

  private
  def generate_token
    loop do
      token = SecureRandom.uuid
      break token unless Account.exists?(auth_token: token)
    end
  end
end

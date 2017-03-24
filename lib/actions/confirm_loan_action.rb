module ConfirmLoanAction
  def self.exec(loan)
    Loan.transaction do
      raise ActiveRecord::Rollback if loan.invalid?
      loan.lender.take_out(loan.amount)
      loan.borrower.put_in(loan.amount)
      loan.update!(confirmed: true)
    end
  end
end

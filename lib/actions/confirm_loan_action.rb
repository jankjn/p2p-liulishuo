module ConfirmLoanAction
  def self.exec(loan)
    Loan.transaction do
      raise LoanOverflowError if loan.overflow?
      loan.lender.take_out(loan.amount)
      loan.borrower.put_in(loan.amount)
      loan.update!(confirmed: true)
    end
  end
end

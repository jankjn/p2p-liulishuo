module PayBackAction
  def self.exec(lender:, borrower:, amount:)
    PayBack.transaction do
      pay_back = PayBack.new(lender: lender, borrower: borrower, amount: amount)
      raise PayBackOverflowError if pay_back.overflow?
      raise PayBackUnderflowError if pay_back.underflow?
      lender.put_in(amount)
      borrower.take_out(amount)
      pay_back.save!
      pay_back
    end
  end
end

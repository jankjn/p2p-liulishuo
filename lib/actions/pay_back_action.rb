module PayBackAction
  def self.exec(pay_back)
    PayBack.transaction do
      raise PayBackOverflowError if pay_back.overflow?
      raise PayBackUnderflowError if pay_back.underflow?
      pay_back.lender.put_in(pay_back.amount)
      pay_back.borrower.take_out(pay_back.amount)
      pay_back.save!
    end
  end
end

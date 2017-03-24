module PayBackAction
  def self.exec(pay_back)
    PayBack.transaction do
      raise ActiveRecord::Rollback if pay_back.invalid?
      pay_back.save!
      pay_back.lender.put_in(pay_back.amount)
      pay_back.borrower.take_out(pay_back.amount)
    end
  end
end

class PayBack < ApplicationRecord
  belongs_to :borrower, class_name: 'Account'
  belongs_to :lender, class_name: 'Account'

  validates :amount, numericality: { greater_than: 0 }
  validates_each :amount do |record, attr, value|
    record.errors.add(attr, :overflow, message: 'can not pay back more than lends') if record.overflow?
    record.errors.add(attr, :underflow, message: 'borrower can not afford the pay back') if record.underflow?
  end

  def overflow?
    borrower.borrows_from(lender) < self.amount
  end

  def underflow?
    borrower.deposit < self.amount
  end
end

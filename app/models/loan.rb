class Loan < ApplicationRecord
  belongs_to :borrower, class_name: 'Account'
  belongs_to :lender, class_name: 'Account'

  validates :amount, numericality: { greater_than: 0 }
  validates_each :amount do |record, attr, value|
    if record.overflow? && !record.confirmed?
      record.errors.add(attr, :overflow, message: 'money not enough to lend')
    end
  end

  def overflow?
    lender.deposit < self.amount
  end
end

class Account < ApplicationRecord
  has_many :borrows, class_name: 'Loan', foreign_key: :borrower_id
  has_many :lends, class_name: 'Loan', foreign_key: :lender_id
end

class CreatePayBacks < ActiveRecord::Migration[5.0]
  def change
    create_table :pay_backs do |t|
      t.references :borrower, foreign_key: { to_table: :accounts }
      t.references :lender, foreign_key: { to_table: :accounts }
      t.decimal :amount

      t.timestamps
    end
  end
end

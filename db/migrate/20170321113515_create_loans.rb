class CreateLoans < ActiveRecord::Migration[5.0]
  def change
    create_table :loans do |t|
      t.references :borrower, foreign_key: { to_table: :accounts }
      t.references :lender, foreign_key: { to_table: :accounts }
      t.decimal :amount
      t.boolean :confirmed, default: false

      t.timestamps
    end
  end
end

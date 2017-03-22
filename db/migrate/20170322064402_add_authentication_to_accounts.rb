class AddAuthenticationToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :username, :string
    add_index :accounts, :username, unique: true
    add_column :accounts, :password_digest, :string
    add_column :accounts, :auth_token, :string
  end
end

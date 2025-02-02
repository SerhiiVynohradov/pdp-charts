class CreateUserAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :user_accounts do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :auth_protocol, default: 'oauth2'
      t.string :provider
      t.string :provider_account_id

      t.string :access_token
      t.string :token_type, default: 'Bearer'
      t.string :scope
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end

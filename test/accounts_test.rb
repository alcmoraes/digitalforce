require 'test_helper'

class AccountsTest < ActiveSupport::TestCase

  # Create/Delete an account
  test "create/delete account" do

    account = Account.new(name: "Doe Company")

    account.save

    savedAccount = Account.find_by(name: "Doe Company")

    assert_not_nil savedAccount

    assert savedAccount.destroy

  end

  # Create a contact with wrong salesforce parameters
  test "create account with wrong salesforce config parameters" do

    Account.acts_as_account connection: {
        :username => 'dummy@force.com',
        :password => 'dummy',
        :security_token => 'dummy',
        :client_id => 'dummy',
        :client_secret => 'dummy'
    }

    account = Account.new()

    assert_raises(Restforce::AuthenticationError) { account.save }

    Account.acts_as_account connection: Dummy::Application.config.salesforce_config

  end

  # Get list of accounts from salesforce
  test "get accounts list" do

    salesforce_accounts = Account.get_salesforce_accounts

    assert_not_empty salesforce_accounts.first

  end

end

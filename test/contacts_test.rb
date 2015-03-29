require 'test_helper'

class AccountsTest < ActiveSupport::TestCase

  # Create/Delete a contact
  test "create/delete contact" do

    user = User.new(name: "John", last_name: "Doe", account_id: "001o000000SLPXiAAP", email: "jdoe@dummy.com", phone: "555 555 555")

    user.save

    savedUser = User.find_by(name: "John", last_name: "Doe")

    assert_not_nil savedUser

    assert savedUser.destroy

  end

  # Create a contact with wrong salesforce parameters
  test "create contact with wrong salesforce config parameters" do

    User.acts_as_contact connection: {
        :username => 'dummy@force.com',
        :password => 'dummy',
        :security_token => 'dummy',
        :client_id => 'dummy',
        :client_secret => 'dummy'
    }

    user = User.new()

    assert_raises(Restforce::AuthenticationError) { user.save }

    User.acts_as_contact connection: Dummy::Application.config.salesforce_config

  end

  # Get list of contacts from salesforce
  test "get contacts list" do

    salesforce_contacts = User.get_salesforce_contacts

    assert_not_empty salesforce_contacts.first

  end

end

require 'test_helper'

class DigitalforceTest < ActiveSupport::TestCase

  # Tries to create a contact without all required parameters in salesforce_config
  test "create contact without all required parameters" do
    User.acts_as_contact connection: {:username => "johndoe@gmail.com"}

    user = User.new()

    assert_raises(ArgumentError) { user.save }

    User.acts_as_contact connection: Dummy::Application.config.salesforce_config
  end

  # Check if all required parameters in salesforce_config are present
  test "check if salesforce have all required parameters" do
    config = Dummy::Application.config.salesforce_config
    assert (
               config.has_key?(:username) &&
               config.has_key?(:password) &&
               config.has_key?(:security_token) &&
               config.has_key?(:client_id) &&
               config.has_key?(:client_secret)
           )
  end

end

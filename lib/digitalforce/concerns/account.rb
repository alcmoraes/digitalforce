require 'digitalforce/base/connection'

module Digitalforce
  module Concerns
    module Account

      extend ActiveSupport::Concern

      attr_accessor :client

      included do
        before_save :manage_salesforce_account_creation
        before_destroy :manage_salesforce_account_destroy
      end

      module ClassMethods

        def acts_as_account(options = {})
          cattr_accessor :client
          self.client = Digitalforce::Base::Connection.connect options[:connection]
        end

        def get_salesforce_accounts
          cattr_accessor :client
          self.client.query("SELECT Id, name FROM Account")
        end

      end

      def manage_salesforce_account_creation
        if self.new_record? && !self.s_id?
          @accountId = self.client.create('Account', Name: self.name)
          self.s_id = @accountId
        else
          self.client.update('Account', Id: self.s_id, Name: self.name)
        end
      end

      def manage_salesforce_account_destroy
        if self.s_id
          self.client.destroy('Account', self.s_id)
        end
      end

    end
  end
end

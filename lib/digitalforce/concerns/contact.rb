require 'digitalforce/base/connection'

module Digitalforce
  module Concerns
    module Contact

      extend ActiveSupport::Concern

      attr_accessor :client

      included do
        before_save  :manage_salesforce_contact_creation
        before_destroy :manage_salesforce_contact_destroy
      end

      module ClassMethods
        def acts_as_contact(options = {})
          cattr_accessor :client
          self.client = Digitalforce::Base::Connection.connect options[:connection]
        end
      end

      def manage_salesforce_contact_creation
        if self.new_record?
          @userId = self.client.create('Contact', FirstName: self.name, LastName: self.last_name, AccountId: self.account_id, Email: self.email)
          self.s_id = @userId
        else
          self.client.update('Contact', Id: self.s_id, FirstName: self.name, LastName: self.last_name, AccountId: self.account_id, Email: self.email)
        end
        true
      end

      def manage_salesforce_contact_destroy
        if self.s_id?
          self.client.destroy('Contact', self.s_id)
        end
        true
      end

    end
  end
end
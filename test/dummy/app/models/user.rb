class User < ActiveRecord::Base

  include Digitalforce::Concerns::Contact

  belongs_to :User, foreign_key: :User_id, primary_key: :s_id

  acts_as_contact connection: Dummy::Application.config.salesforce_config

  def self.sync

    if !User.isSynced

      get_salesforce_contacts.each do |contact|
        ctc_params = {:s_id => contact.Id, :name => contact.FirstName, :last_name => contact.LastName, :phone => contact.Phone, :account_id => contact.AccountId}
        if User.exists?(:s_id => contact.Id)
          ctc = User.find(contact.Id)
          ctc.update(ctc_params)
        else
          ctc = User.new(ctc_params)
          ctc.save
        end
      end

    end

  end

  def self.isSynced

    salesforceContacts = get_salesforce_contacts
    databaseCount = User.count

    if salesforceContacts.count != databaseCount
      false
    else
      true
    end

  end

end

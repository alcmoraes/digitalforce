class Account < ActiveRecord::Base

  include Digitalforce::Concerns::Account

  has_many :users, foreign_key: :account_id, primary_key: :s_id, dependent: :destroy

  acts_as_account connection: Dummy::Application.config.salesforce_config

  def self.sync

    if !Account.isSynced

        get_salesforce_accounts.each do |account|
          acc_params = {:s_id => account.Id, :name => account.Name}
          if Account.exists?(:s_id => account.Id)
            acc = Account.find(account.Id)
            acc.update(acc_params)
          else
            acc = Account.new(acc_params)
            acc.save
          end
        end

    end

  end

  def self.isSynced

    salesforceAccounts = get_salesforce_accounts
    databaseCount = Account.count

    if salesforceAccounts.count != databaseCount
      false
    else
      true
    end

  end

end

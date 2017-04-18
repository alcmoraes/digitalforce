Resultados Digitais - RoR Challenge

Obs.: This was a challenge made by @alcmoraes for Resultados Digitais agency

[![Gem Version](https://badge.fury.io/rb/digitalforce.svg)](http://badge.fury.io/rb/digitalforce)
[![Dependency Status](https://gemnasium.com/kalvinmoraes/digitalforce.svg)](https://gemnasium.com/kalvinmoraes/digitalforce)
[![Code Climate](https://codeclimate.com/github/kalvinmoraes/digitalforce/badges/gpa.svg)](https://codeclimate.com/github/kalvinmoraes/digitalforce)

Digitalforce is a ruby gem made to keep it simple to control your Contacts/Accounts in [Salesforce](http://www.salesforce.com), taking advantage of [Restforce](https://github.com/ejholmes/restforce) to do the API requests, offering greater flexibility.

Features include:

* Create, Edit, Update and Destroy Contacts/Accounts from Salesforce direct from your rails application
* Easily [synchronize](https://github.com/kalvinmoraes/digitalforce/blob/master/README.md#synchronizing) Contacts and Accounts from Salesforce with your database by using the get_salesforce_[accounts/contacts] method

## Installation

Add this line to your application's Gemfile:

    gem 'digitalforce'

And then execute:

    $ bundle

---

## Usage

To Digitalforce works, your models need to be tweeked a little. But don't worry. We'll be talking about all changes in details.

### Configuration

The first you'll need to do is to edit your ``config/application.rb`` file and set the following:

```ruby
config.salesforce_config = {
    :username => '{your_sales_force_username}',
    :password => '{your_password}',
    :security_token => '{security_token}',
    :client_id => '{giant_client_id}',
    :client_secret => '{client_secret}'
}
```

> **As you can notice, we're not using the "password+securityToken" as documented in Salesforce. That's because Restforce do this for you. Keeping your configuration organized.**

### Models

Here you do your magic to keep your models synced with Salesforce objects.

First you'll need to have a Contact and Account models with a ``Contact belongs_to Account`` association.

Do your migrations thing using the fields below:

> **Note** *that you can add as many fields as you want for both tables, but only the described below will be synced with Salesforce, and because of that, this is mandatory*

**Contact**
* name
* last_name
* email
* phone
* account_id

**Account**
* name

After the magic ends, the following changes will need to be done in your migration file:

* Set both tables primary key to be string => **:s_id**
* The **:account_id** in **Contacts** should be set as **index** and **string**

**Here is how the file should look like**

> **Note** *that we added more fields in Contacts model as we said before and changed the Migrations name for CreateTables*

```ruby
class CreateTables < ActiveRecord::Migration
  def change
    create_table :contacts, :primary_key => :s_id do |t|
      t.string :name
      t.string :last_name
      t.string :email
      t.string :company
      t.string :job_title
      t.string :phone
      t.string :website
      t.string :account_id

      t.timestamps null: false
    end

    create_table :accounts, :primary_key => :s_id do |t|
      t.string :name
      
      t.timestamps null: false
    end

    change_column :accounts, :s_id, :string
    change_column :contacts, :s_id, :string

    add_index :contacts, :account_id

  end
end
```

**That's it? No :(**

Because Rails are not meant to work in that way, we need to set the **foreign_key** inside the models as well.

``application/app/models/account.rb``
```ruby
class Account < ActiveRecord::Base

  has_many :contacts, foreign_key: :account_id, primary_key: :s_id, dependent: :destroy
  
end
```

> **Here we set the contact's association, dependent. This way when you delete an Account it will automatically exclude all Contacts. For documentation reasons we use it, but it's not mandatory.**

``application/app/models/contact.rb``
```ruby
class Contact < ActiveRecord::Base

  belongs_to :account, foreign_key: :account_id, primary_key: :s_id
  
end
```

### Integration with Digitalforce

Now that you have your pretty models ready to go on fire, let's integrate with Digitalforce

``application/app/models/contact.rb``
```ruby
class Contact < ActiveRecord::Base

  include Digitalforce::Concerns::Contact
  acts_as_contact connection: YourApp::Application.config.salesforce_config

  belongs_to :account, foreign_key: :account_id, primary_key: :s_id
  
end
```

``application/app/models/account.rb``
```ruby
class Account < ActiveRecord::Base

  include Digitalforce::Concerns::Account
  acts_as_account connection: YourApp::Application.config.salesforce_config

  has_many :contacts, foreign_key: :account_id, primary_key: :s_id, dependent: :destroy
  
end
```

**Ta Da!** You have done almost everything to start syncing your objects with Salesforce. Let's learn about these last modifications:

* We've included the **Digitalforce::Concerns** inside **Contact** and **Account** to get access to ours **acts_as_XXXX** behavior
* We've used **acts_as_contact** and **acts_as_account** inside our models passing the **connection** parameter that will be carrying, guess what? Yay! Your *salesforce_config* config parameter created in the first step.

### Synchronizing

See these snippets to learn how to integrate a sync tool into your **Contact** and **Account** model

``application/app/models/account.rb``
```ruby
class Account < ActiveRecord::Base
    ...
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
        if salesforceAccounts.count == databaseCount
          true
        else
          false
        end
    end
    ...
end
```

Using the **get_salesforce_[accounts/contacts]** method you can easily manage a synchronizing tool.
In the above example we've added to **Account** model the functionality to check if the database is synced with salesforce and a method to sync it (**self.isSynced** and **self.sync**)

Taking this in advantage, you can now create a small snippet inside your ``application/app/views/accounts/index.html.erb`` just above the table iterating the account list, like this:

```ruby
<% if !Account.isSynced %>
    The local data is not synced with Salesforce. <%= link_to 'Sync now!', '/accounts/sync' %>
<% end %>
```

You see what we've done here? We've used our brand new **isSynced** method from our Account model.
If you run your server and click in "Sync now!", you'll probably get an error because you have not set the routes for **/accounts/sync**

``application/config/routes.db``

```ruby
get 'accounts/sync' => 'accounts#sync'
```

And, of course, in our **AccountsController**:

``application/app/controllers/accounts_controller``
```ruby
class AccountsController < ApplicationController
    ...
    def sync
        Account.sync
        redirect_to accounts_path
    end
    ...
end
```

---

## Warnings, gotchas and tips

Salesforce demands that a **Contact** belongs to an **Account**, so add **:required => true** to the Account dropdown:

```ruby
<%= f.collection_select(:account_id, Account.all, :s_id, :name, {:prompt => "Select your account"}, {:required => true}) %>
```

Also, it's necessary to send a **LastName**, so do the *required* thing in this field too:

```ruby
<%= f.text_field :last_name, :required => true %>
```

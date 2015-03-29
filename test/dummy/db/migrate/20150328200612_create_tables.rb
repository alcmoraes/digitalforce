class CreateTables < ActiveRecord::Migration
  def change
    create_table :users, :primary_key => :s_id do |t|
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
    change_column :users, :s_id, :string

    add_index :users, :account_id

  end
end

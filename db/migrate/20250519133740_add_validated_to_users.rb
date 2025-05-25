class AddValidatedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :validated, :boolean, default: false
  end
end

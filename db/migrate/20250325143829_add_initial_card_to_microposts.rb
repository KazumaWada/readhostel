class AddInitialCardToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :initial_card, :boolean, default: false
  end
end

class AddOriginalToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :original, :string
  end
end

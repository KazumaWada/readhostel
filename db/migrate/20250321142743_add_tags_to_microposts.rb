class AddTagsToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :tags, :string
  end
end

class RenameStatusToPostStatusInMicroposts < ActiveRecord::Migration[8.0]
  def change
    rename_column :microposts, :status, :post_status
  end
end

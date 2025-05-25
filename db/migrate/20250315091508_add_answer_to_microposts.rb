class AddAnswerToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :answer, :text
  end
end

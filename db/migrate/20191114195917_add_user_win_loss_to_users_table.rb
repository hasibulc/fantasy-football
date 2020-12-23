class AddUserWinLossToUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :user_wins, :integer
    add_column :users, :user_losses, :integer
  end
end

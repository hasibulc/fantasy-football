class AddWinsLossesToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :team_wins, :integer
    add_column :teams, :team_losses, :integer
  end
end

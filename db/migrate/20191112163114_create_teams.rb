class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :team_name
      t.string :player1
      t.string :player2
      t.string :player3
      t.string :player4
      t.string :player5
      t.string :player6
      t.string :player7
      t.string :player8
      t.string :player9
      t.string :player10
      t.string :player11
      t.integer :user_id
    end
  end
end

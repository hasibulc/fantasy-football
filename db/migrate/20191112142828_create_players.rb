class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :goals_scored
      t.integer :goals_conceded
      t.integer :goals_assisted
      t.float :rating
    end
  end
end

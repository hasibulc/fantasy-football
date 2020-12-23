# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_15_145137) do

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "goals_scored"
    t.integer "goals_conceded"
    t.integer "goals_assisted"
    t.float "rating"
  end

  create_table "teams", force: :cascade do |t|
    t.string "team_name"
    t.string "player1"
    t.string "player2"
    t.string "player3"
    t.string "player4"
    t.string "player5"
    t.string "player6"
    t.string "player7"
    t.string "player8"
    t.string "player9"
    t.string "player10"
    t.string "player11"
    t.integer "user_id"
    t.integer "team_wins"
    t.integer "team_losses"
  end

  create_table "users", force: :cascade do |t|
    t.string "user"
    t.string "password"
    t.integer "user_wins"
    t.integer "user_losses"
  end

end

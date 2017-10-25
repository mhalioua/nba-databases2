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

ActiveRecord::Schema.define(version: 20171022215003) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "nbas", force: :cascade do |t|
    t.string "home_team"
    t.string "away_team"
    t.integer "game_id"
    t.string "game_date"
    t.string "home_abbr"
    t.string "away_abbr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "away_last_game"
    t.integer "away_next_game"
    t.integer "away_first_quarter"
    t.integer "away_second_quarter"
    t.integer "away_third_quarter"
    t.integer "away_forth_quarter"
    t.integer "away_ot_quarter"
    t.integer "home_last_game"
    t.string "home_last_fly"
    t.integer "home_next_game"
    t.string "home_next_fly"
    t.integer "home_first_quarter"
    t.integer "home_second_quarter"
    t.integer "home_third_quarter"
    t.integer "home_forth_quarter"
    t.integer "home_ot_quarter"
    t.integer "away_score"
    t.integer "home_score"
    t.integer "total_score"
    t.integer "first_point"
    t.integer "second_point"
    t.integer "total_point"
    t.float "first_line"
    t.float "second_line"
    t.float "full_line"
    t.float "first_side"
    t.float "second_side"
    t.float "full_side"
    t.string "year"
    t.string "date"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

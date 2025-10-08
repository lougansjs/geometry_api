# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_01_023751) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "circles", force: :cascade do |t|
    t.decimal "diameter", precision: 10, scale: 2, null: false
    t.decimal "center_x", precision: 10, scale: 2, null: false
    t.decimal "center_y", precision: 10, scale: 2, null: false
    t.integer "frame_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["center_x", "center_y"], name: "index_circles_on_center_x_and_center_y"
    t.index ["frame_id", "center_x", "center_y"], name: "index_circles_on_frame_id_and_center_x_and_center_y"
    t.index ["frame_id"], name: "index_circles_on_frame_id"
    t.check_constraint "diameter > 0::numeric", name: "check_diameter_check"
  end

  create_table "frames", force: :cascade do |t|
    t.decimal "width", precision: 10, scale: 2, null: false
    t.decimal "height", precision: 10, scale: 2, null: false
    t.decimal "center_x", precision: 10, scale: 2, null: false
    t.decimal "center_y", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "height > 0::numeric", name: "check_height_check"
    t.check_constraint "width > 0::numeric", name: "check_width_check"
  end

  add_foreign_key "circles", "frames", on_delete: :restrict
end

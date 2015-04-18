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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100911020048) do

  create_table "quakes", :force => true do |t|
    t.datetime "strike_time"
    t.float    "magnitude"
    t.float    "depth"
    t.float    "lat"
    t.float    "lng"
    t.string   "external_ref"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quakes", ["depth"], :name => "index_quakes_on_depth"
  add_index "quakes", ["external_ref"], :name => "index_quakes_on_external_ref"
  add_index "quakes", ["magnitude"], :name => "index_quakes_on_magnitude"
  add_index "quakes", ["strike_time"], :name => "index_quakes_on_strike_time"

end

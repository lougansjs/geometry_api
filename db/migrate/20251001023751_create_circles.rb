class CreateCircles < ActiveRecord::Migration[8.0]
  def change
    create_table :circles do |t|
      t.decimal :diameter, precision: 10, scale: 2, null: false
      t.decimal :center_x, precision: 10, scale: 2, null: false
      t.decimal :center_y, precision: 10, scale: 2, null: false
      t.references :frame, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps
    end

    add_check_constraint :circles, "diameter > 0", name: "check_diameter_check"

    add_index :circles, [ :center_x, :center_y ], name: "index_circles_on_center_x_and_center_y"
    add_index :circles, [ :frame_id, :center_x, :center_y ], name: "index_circles_on_frame_id_and_center_x_and_center_y"
  end
end

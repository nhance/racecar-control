class CreatePointsAdjustments < ActiveRecord::Migration
  def change
    create_table :points_adjustments do |t|
      t.references :race
      t.references :registration

      t.integer :points
      t.string  :reason

      t.timestamps null: false
    end
  end
end

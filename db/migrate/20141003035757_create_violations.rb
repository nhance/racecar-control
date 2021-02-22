class CreateViolations < ActiveRecord::Migration
  def change
    create_table :violations do |t|
      t.integer :scan_id
      t.text :comment

      t.timestamps
    end
  end
end

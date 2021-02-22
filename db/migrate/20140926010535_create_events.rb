class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :track
      t.date :start_date
      t.date :stop_date

      t.timestamps
    end
  end
end

class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.integer :event_price_in_cents
    end

    execute "ALTER TABLE seasons AUTO_INCREMENT = 2015;"

    add_column :cars, :season_id, :integer
    add_column :events, :season_id, :integer
  end
end

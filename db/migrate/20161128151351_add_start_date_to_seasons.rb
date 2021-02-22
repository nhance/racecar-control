class AddStartDateToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :start_date, :date

    Season.all.each do |season|
      season.start_date = Date.parse("#{season.id}-01-01")
      season.save
    end
  end
end

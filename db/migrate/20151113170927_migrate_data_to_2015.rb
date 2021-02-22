class MigrateDataTo2015 < ActiveRecord::Migration
  def change
    Season.find_or_create_by(id: 2015) if defined?(Season)

    if (Date.today.year == 2015)
      execute("UPDATE events SET season_id = 2015;")
      execute("UPDATE cars SET season_id = 2015;")
    end
  end
end

class QualifyingController < ApplicationController
  include LapTimeHelper

  def index
    respond_to do |format|
      format.html
      format.csv { send_data get_csv }
      # format.txt { render plain: get_csv }
    end

  end

private
  def get_csv
    teams = LapTimeHelper.teams_by_qualifying_time
    overall_fastest_time = LapTimeHelper.qualifying_ftd
    columns = %w{ team_name car_number time speed delta overall_delta}
    CSV.generate do |csv|
      csv << columns
      teams.each_with_index do |team, index|
        fastest_time = team.fastest_qualifying_time
        overall_delta = (index != 0) ? overall_fastest_time - fastest_time : 0.000
        delta = (index != 0) ? teams[index - 1].fastest_qualifying_time - fastest_time : 0.000

        csv << [ team.team_name,
                 team.car_number,
                 fastest_time,
                 team.fastest_qualifying_speed,
                 delta,
                 overall_delta
        ]
      end
    end
  end
end

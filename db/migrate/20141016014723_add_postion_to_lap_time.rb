class AddPostionToLapTime < ActiveRecord::Migration
  def change
    add_column :lap_times, :position, :integer
  end
end

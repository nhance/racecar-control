class AddTrackLengthToEvent < ActiveRecord::Migration
  def change
    add_column :events, :track_length, :float
  end
end

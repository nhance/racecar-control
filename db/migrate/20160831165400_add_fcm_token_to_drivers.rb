class AddFcmTokenToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :fcm_token, :string
  end
end

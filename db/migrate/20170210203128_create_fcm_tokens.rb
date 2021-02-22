class CreateFcmTokens < ActiveRecord::Migration
  def change
    create_table :fcm_tokens do |t|
      t.belongs_to :driver
      t.string :token
      t.timestamps
    end
  end
end

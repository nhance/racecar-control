class CreateSmsMessages < ActiveRecord::Migration
  def change
    create_table :sms_messages do |t|
      t.string :number
      t.string :message
      t.timestamp :sent_at
      t.references :resource, polymorphic: true
      t.timestamps
    end
  end
end

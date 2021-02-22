class AddDriverContactOptionsAndShirtSize < ActiveRecord::Migration
  def change
    add_column :drivers, :allow_sms, :boolean, default: true
    add_column :drivers, :shirt_size, :string
  end
end

class AddCellPhoneToDriver < ActiveRecord::Migration
  def change
    add_column :drivers, :cell_phone, :string
  end
end

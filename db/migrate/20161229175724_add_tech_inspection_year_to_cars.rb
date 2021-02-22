class AddTechInspectionYearToCars < ActiveRecord::Migration
  def change
    add_column :cars, :tech_inspection_year, :integer
  end
end

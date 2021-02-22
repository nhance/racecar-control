class AddAbbrToEvents < ActiveRecord::Migration
  def change
    add_column :events, :abbr, :string
  end
end

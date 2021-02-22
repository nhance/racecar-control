class AddDriverCommentsAndApprovalAndReservableActivation < ActiveRecord::Migration
  def change
    add_column :drivers, :approved_at, :timestamp
    add_column :drivers, :internal_comments, :text

    add_column :reservable_items, :visible_to_drivers, :boolean, default: false
  end
end

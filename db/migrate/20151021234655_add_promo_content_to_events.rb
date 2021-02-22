class AddPromoContentToEvents < ActiveRecord::Migration
  def change
    add_column :events, :promo_content, :text
  end
end

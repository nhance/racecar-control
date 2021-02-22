class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string :name
      t.string :url
      t.references :attached_to, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end

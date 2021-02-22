class CreateScanAudits < ActiveRecord::Migration
  def change
    create_table :scan_audits do |t|
      t.string :response_code
      t.string :barcode
      t.string :message
      t.string :pit

      t.timestamps
    end
  end
end

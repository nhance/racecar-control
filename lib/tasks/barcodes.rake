require 'colorize'

namespace :barcodes do
  desc "Generate All Barcodes"
  task :generate => :environment do
    begin
      puts "Generating all barcodes...".green
      puts "\tGenerating driver barcodes...".green
      Driver.all.each { |d| d.generate_barcode }
      puts "\tGenerating car barcodes...".green
      Car.all.each { |c| c.generate_barcode }
    rescue
      puts "There was a problem genearating barcodes".red and raise
    end
  end
  desc "Delete All Barcodes"
  task :delete => :environment do
    begin
      dir_path = Driver.last.barcode_path
      puts "\tDeleting driver barcodes...".green
      FileUtils.rm_rf(Dir.glob("#{dir_path}/*.png"), secure: true)
      dir_path = Car.last.barcode_path
      puts "\tDeleting car barcodes...".green
      FileUtils.rm_rf(Dir.glob("#{dir_path}/*.png"), secure: true)
    rescue
      puts "There was a problem deleting barcodes".red and raise
    end
  end
  namespace :generate do
    desc "Generate Driver Barcodes"
    task :drivers => :environment do
      puts "\tGenerating driver barcodes...".green
      Driver.all.each { |d| d.generate_barcode }
    end
    desc "Generate Car Barcodes"
    task :cars => :environment do
      puts "\tGenerating car barcodes...".green
      Car.all.each { |c| c.generate_barcode }
    end
  end
end

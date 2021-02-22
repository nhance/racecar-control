#!/usr/bin/env ruby

require_relative '../config/environment'
require 'optparse'

def generate_drivers
  puts "Generating driver barcodes..."
  Driver.all.each { |d| d.generate_barcode }
end

def generate_cars
  puts "Generating car barcodes..."
  Car.all.each { |c| c.generate_barcode }
end

options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: generate_barcodes.rb [options]"
  options[:all] = false
  opts.on( '-a', '--all', 'Generate all barcodes (driver & car)' )  do
    options[:all] = true
  end
  options[:drivers] = false
  opts.on( '-d', '--drivers', 'Generate all driver barcodes' )  do
    options[:drivers] = true
  end
  options[:cars] = false
  opts.on( '-c', '--cars', 'Generate all car barcodes' )  do
    options[:cars] = true
  end
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end 
end

optparse.parse!

if options[:all]
  generate_drivers
  generate_cars
elsif options[:drivers]
  generate_drivers
elsif options[:cars]
  generate_cars
end

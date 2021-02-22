#!/usr/bin/env ruby

require "socket"

test_file = 'examples/aer_wgi_day_2.csv'
f = File.new(test_file, "r")

skip_to = ARGV[0].to_i || 1

oss = TCPServer.new('0.0.0.0', 50000)
begin
  puts "Listening on port 50000 for Orbits connection"
  loop do
    if s = oss.accept
      begin
        if skip_to > 1
          puts "Skipping to start on line number #{skip_to}"
          skip_to.times { f.gets }
        end
        print(s, " is accepted\n")
        f.each_line do |line|
          s.write(line)
          puts(line)
          sleep 0.1 if line.start_with?("$F")
        end
      rescue Errno::EPIPE
        print(s, " is gone\n")
        s.close
        f.rewind
      end
    end
  end
ensure
  puts "Shutting down"
  # need to look into shutdown
  oss.close unless oss.closed?
  f.close
end

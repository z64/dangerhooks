require 'bundler/setup'
require_relative 'src/journal'

# Create a new journal
# TODO: Pick up when a new journal file is made
j = Journal.new Dir["#{GAME_DIR}/*"].last

# Poll it every 0.3s
# TODO: Make this configurable
loop do
  j.poll!
  sleep 0.3
end

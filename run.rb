require_relative 'src/client'

# Grab the latest journal
j = Journal.latest

# Keep process alive
loop {}

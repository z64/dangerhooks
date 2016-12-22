require_relative 'src/client'

# Grab the latest journal
j = Journal.latest

# Set up scheduler to process events
# TODO: If a newer file becomes available, grab that one.
SCHEDULER.every CONFIG.interval do
  j.poll
end

# Keep process alive
loop {}

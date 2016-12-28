# Stdlib
require 'json'
require 'yaml'
require 'logger'

# Gems
require 'bundler/setup'
require 'listen'
require 'discordrb/webhooks'

# Configuration
CONFIG = OpenStruct.new YAML.load_file 'config.yaml'
LOGGER = Logger.new $stdout
GAME_DIR = "C:/Users/#{CONFIG.user}/Saved Games/Frontier Developments/Elite Dangerous"

# Load handlers
Dir.glob('handlers/*.rb') { |mod| load mod }


def latest_event(file)
  # Container for events in this file
  events = []

  # Parse each event
  File.new(file).each_line do |l|
    begin
      events << JSON.parse(l)
    rescue JSON::ParserError
      LOGGER.warn 'Caught a JSON object mid-flush somehow.. skipping!'
    end
  end

  # Handle the most recent event
  event = events.last

  # Keep commander name with all events
  commander_event = events.find { |e| e.has_key? 'Commander' }
  event['Commander'] ||= commander_event['Commander']

  event
end

# Take an event, search for a handler, and return
# an object we can send off to Discord
def handle(event)
  handler = Handlers.const_get event['event'].to_sym
  handler.handle event
rescue
  LOGGER.info "Unsupported event #{event['event']} => #{event}"
end

# Listen to the log directory, and handle events
listener = Listen.to(GAME_DIR, only: /\.log$/) do |m, a, r|
  m.each do |f|
    handle latest_event f
  end
end

listener.start

sleep

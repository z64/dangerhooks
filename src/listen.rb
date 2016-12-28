# Stdlib
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

# Load webhooks
WEBHOOKS = CONFIG.webhooks.map { |url| Discordrb::Webhooks::Client.new url: url }

# Load handlers
module Handler ; end
Dir.glob('src/handlers/*.rb') { |mod| load mod }

def latest_event(file)
  # Container for events in this file
  events = []

  # Parse each event
  File.new(file).each_line do |l|
    begin
      events << JSON.parse(l)
    rescue JSON::ParserError
      LOGGER.warn 'Caught a JSON object mid-flush (or otherwise corrupt) somehow.. skipping!'
      next
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
  return unless CONFIG.events.include? event['event']

  handler = Handler.const_get event['event'].to_sym
  embed = handler.handle event

  LOGGER.info "Handled event #{event['event']} => #{event}"

  return unless embed

  Discordrb::Webhooks::Builder.new(
    username: "CMDR #{event['Commander']}",
    embeds: [embed]
  )
rescue
  LOGGER.info "Unsupported event #{event['event']} => #{event}"
  nil
end

# Take an embed and broadcast it to all of our webhooks
def syndicate(builder)
  WEBHOOKS.each { |w| w.execute(builder) {} }
end

# Listen to the log directory, and handle events
listener = Listen.to(GAME_DIR, only: /\.log$/) do |m, a, r|
  m.each do |f|
    event = latest_event f
    builder = handle event
    syndicate builder if builder
  end
end

listener.start

sleep

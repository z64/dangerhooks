# Stdlib
require 'yaml'
require 'logger'

# Gems
require 'discordrb/webhooks'

# Configuration
CONFIG = OpenStruct.new YAML.load_file 'config.yaml'
LOGGER = Logger.new $stdout
GAME_DIR = "C:/Users/#{ENV['USERNAME']}/Saved Games/Frontier Developments/Elite Dangerous"

# Load webhooks
WEBHOOKS = CONFIG.webhooks.map { |url| Discordrb::Webhooks::Client.new url: url }

# Load handlers
module Handler ; end
Dir.glob('src/handlers/*.rb') { |mod| load mod }

# Take an event, search for a handler, and return
# an object we can send off to Discord
def handle(event)
  return unless CONFIG.events.include? event['event']

  LOGGER.info "Received event #{event['event']} => #{event}"

  handler = Handler.const_get event['event'].to_sym
  embed = handler.handle event

  return unless embed

  LOGGER.info "Handled event #{event['event']}"

  Discordrb::Webhooks::Builder.new(
    username: "CMDR #{event['Commander']}",
    embeds: [embed]
  )
rescue
  LOGGER.warn "Unsupported event #{event['event']} => #{event}"
  nil
end

# Take an embed and broadcast it to all of our webhooks
def syndicate(builder)
  WEBHOOKS.each { |w| w.execute(builder) }
end

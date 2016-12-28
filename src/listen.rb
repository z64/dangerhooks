# Stdlib
require 'yaml'
require 'logger'

# Gems
require 'bundler/setup'
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
  LOGGER.info "Unsupported event #{event['event']} => #{event}"
  nil
end

# Take an embed and broadcast it to all of our webhooks
def syndicate(builder)
  WEBHOOKS.each { |w| w.execute(builder) {} }
end

class Journal
  # @return [String] journal file this object is attached to
  attr_reader :filename

  # @return [Hash<Integer, Hash>] cache of events in this journal
  attr_reader :events

  # @return [Integer] last read event of this journal
  attr_reader :last_read

  # @return [String] name of cmdr the log belongs to
  attr_reader :commander

  def initialize(filename)
    @filename = filename
    @events = []
  end

  # Process events in this file
  def poll!
    # Load and update all events
    load_events

    # ignore first time load so we don't spam the endpoint
    if @last_read.nil?
      @last_read = @events.count
      return
    end

    # handle unread events
    @events[@last_read..-1].each do |e|
      next unless CONFIG.events.include? e['event']
      builder = handle e
      syndicate builder
    end

    @last_read = @events.count
  end

  private

  def load_events
    File.new(@filename).each_line.with_index do |data, id|
      begin
        event = JSON.parse data
        @commander = event['Commander'] if event.has_key? 'Commander'
        event['Commander'] ||= @commander
        @events[id] = event
      rescue JSON::ParserError
        @events[id] = nil
      end
    end
  end
end

j = Journal.new Dir["#{GAME_DIR}/*"].last

loop do
  j.poll!
  sleep 0.3
end

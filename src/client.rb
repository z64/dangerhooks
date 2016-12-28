# Dependencies
require 'bundler/setup'
require 'rest-client'
require 'listen'

# Stdlib
require 'yaml'
require 'json'
require 'ostruct'
require 'time'
require 'logger'

# Logger
LOGGER = Logger.new $stdout

# Configuration
CONFIG = OpenStruct.new YAML.load_file 'config.yaml'

# Game directory
GAME_DIR = "C:/Users/#{CONFIG.user}/Saved Games/Frontier Developments/Elite Dangerous"

class Journal
  # @return [String] filename of the loaded journal
  attr_reader :file

  # @return [Integer] last event line read
  attr_reader :last_read

  # @return [Hash] hash of all cached events thus far
  attr_reader :events

  # @return [String] name of commander the journal file belongs to
  attr_reader :commander

  # @return [true, false] whether this is our first-time read or not
  attr_reader :init

  # Hook a journal onto the specified file.
  # By default, it will start pushing events after
  # the time the Journal was created.
  def initialize(file, last_read = 0)
    @file = file
    @last_read = last_read
    @events = []
  end

  # Poll the journal for events that we haven't
  # sent yet to the service.
  def poll
    File.new(@file).each_line.with_index do |l, i|
    begin
      object = JSON.parse l
      @commander ||= object['Commander']
    rescue JSON::ParserError
      LOGGER.warn 'Caught a JSON object mid-flush.. skipping!'
      next
    end

      object['timestamp'] = Time.parse object['timestamp']
      object['Commander'] = @commander unless object.has_key? 'Commander'

      next unless i > @last_read

      @events << object

      @last_read = i

      # Don't spam the API with events on our first time read
      next unless @init

      # Ignore any event the client hasn't specified
      # that they want POSTed.
      post object if CONFIG.events.include? object['event']
    end

    @init = true
  end

  # Send an event to the service
  # @param event [Hash] payload to send
  def post(event)
    CONFIG.webhooks.each do |w|
      begin
        LOGGER.info "POST #{event.to_json}"
        RestClient.post CONFIG.api_url, event, { content_type: 'application/json' }
      rescue => e
        LOGGER.error "Could not POST! #{e}"
        next
      end
    end
  end

  # Attempt to grab the latest journal file
  # in the GAME_DIR
  def self.latest
    new Dir.glob("#{GAME_DIR}/*").last
  end
end

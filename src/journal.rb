require_relative 'handler'

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

      syndicate builder if builder
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

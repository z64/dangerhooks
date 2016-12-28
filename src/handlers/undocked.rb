# Triggered when a player undocks from a station
# { "timestamp":"2016-12-22T00:21:17Z", "event":"Undocked", "StationName":"Bohme's Folly" }
module Handler::Undocked
  def self.handle(event)
    Discordrb::Webhooks::Embed.new(
      description: "Undocked from #{event['StationName']}",
      timestamp: Time.parse(event['timestamp'])
    )
  end
end

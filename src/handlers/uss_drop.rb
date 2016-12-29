# Triggered when a player drops out at a USS
# {
#   "timestamp": "2016-06-10T14:32:03Z",
#   "event": "USSDrop",
#   "USSType": "Disrupted wake echoes",
#   "USSThreat": 0
# }
module Handler::USSDrop
  def self.handle(event)
    e = Discordrb::Webhooks::Embed.new(
      description: 'Dropped out at a USS',
      timestamp: Time.parse(event['timestamp'])
    )

    e.add_field(
      name: 'USS Info',
      value: "#{event['USSType']} (threat level #{event['USSThreat']})"
    )

    e
  end
end

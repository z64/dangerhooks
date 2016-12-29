# Triggered when a player self-destructs
# { "timestamp": ..., "event": "SelfDestruct" }
module Handler::SelfDestruct
  def self.handle(event)
    Discordrb::Webhooks::Embed.new(
      description: '**Self desctructed!**',
      color: 0xff0000,
      timestamp: Time.parse(event['timestamp'])
    )
  end
end

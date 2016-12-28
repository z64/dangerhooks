# Triggered when a player sends text to someone
# {
#   "timestamp": "2016-12-22T02:00:36Z",
#   "event": "SendText",
#   "To": "local",
#   "Message": "test"
# }
module Handler::SendText
  # Because of the nature of this event, it has special
  # behavior to only return an Embed if your message
  # is to local chat and has a special prefix, i.e. '@d hi there'
  # @TODO: Make this configurable
  def self.handle(event)
    return unless event['Message'].start_with? '@d'

    Discordrb::Webhooks::Embed.new(
      description: event['Message'][2..-1],
      timestamp: Time.parse(event['timestamp'])
    )
  end
end

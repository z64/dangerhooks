# Triggered when a player joins a wing with other CMDRs
# {
#   "timestamp": "2016-12-19T03:43:58Z",
#   "event": "WingJoin",
#   "Others": [
#     "SkybornSnowhawk",
#     "Atmora"
#   ]
# }
module Handler::WingJoin
  def self.handle(event)
    others = others_string(event['Others'])

    Discordrb::Webhooks::Embed.new(
      description: "Winged up with #{others}!",
      timestamp: Time.parse(event['timestamp'])
    )
  end

  # TODO: Handle this nicely so that it writes 'Person, Person, and Person', etc.
  def self.others_string(names)
    names.join ', '
  end
end

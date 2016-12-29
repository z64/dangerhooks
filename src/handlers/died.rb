# Triggered when a player dies
# When killed by a solo ship:
# {
#   "timestamp": "2016-06-10T14:32:03Z",
#   "event": "Died",
#   "KillerName": "$ShipName_Police_Independent;",
#   "KillerShip": "viper",
#   "KillerRank": "Deadly"
# }
# When killed by a wing:
# {
#   "timestamp": "2016-06-10T14:32:03Z",
#   "event": "Died",
#   "Killers": [
#     {
#       "Name": "Cmdr HRC1",
#       "Ship": "Vulture",
#       "Rank": "Competent"
#     },
#     {
#       "Name": "Cmdr HRC2",
#       "Ship": "Python",
#       "Rank": "Master"
#     }
#   ]
# }
module Handler::Died
  def self.handle(event)
    e = Discordrb::Webhooks::Embed.new(
      description: "Killed by a #{event['KillerRank']} #{event['KillerShip']}!",
      color: 0xff0000,
      timestamp: Time.parse(event['timestamp'])
    )

    e.description = "Killed by a wing of #{event['Killers'].count} ships!" if event.has_key? 'Killers'

    e
  end
end

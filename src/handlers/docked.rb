# Triggered when a player docks at a station
# {
#   "timestamp": "2016-12-22T00:14:43Z",
#   "event": "Docked",
#   "StationName": "Bohme's Folly",
#   "StarSystem": "Phrasika",
#   "StationFaction": "Loren's Legion",
#   "FactionState": "Boom",
#   "StationGovernment": "$government_Patronage;",
#   "StationGovernment_Localised": "Patronage",
#   "StationAllegiance": "Empire",
#   "StationEconomy": "$economy_Refinery;",
#   "StationEconomy_Localised": "Refinery"
# }
module Handler::Docked
  def self.handle(event)
    e = Discordrb::Webhooks::Embed.new(
      description: "Docked at **#{event['StationName']}** in **#{event['StarSystem']}**",
      color: 0x0000ff,
      timestamp: Time.parse(event['timestamp'])
    )

    e.add_field(
      name: 'Station Info',
      value: <<~info
       Faction: `#{event['StationFaction']} [#{event['FactionState']}]`
       Government: `#{event['StationGovernment_Localised']}`
       Allegiance: `#{event['StationAllegiance']}`
       Economy: `#{event['StationEconomy_Localised']}`
      info
    )

    e
  end
end

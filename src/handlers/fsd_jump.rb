# Triggered when a player jumps to another system
# {
#   "timestamp": "2016-10-12T02:34:59Z",
#   "event": "FSDJump",
#   "StarSystem": "Ross 199",
#   "StarPos": [
#     -101.969,
#     0.969,
#     -11.781
#   ],
#   "Allegiance": "Federation",
#   "Economy": "$economy_Industrial;",
#   "Economy_Localised": "Industrial",
#   "Government": "$government_Corporate;",
#   "Government_Localised": "Corporate",
#   "Security": "$SYSTEM_SECURITY_medium;",
#   "Security_Localised": "Medium Security",
#   "Powers": [
#     "Pranav Antal"
#   ],
#   "PowerplayState": "Exploited",
#   "JumpDist": 9.833,
#   "FuelUsed": 5.124792,
#   "FuelLevel": 26.875208,
#   "Faction": "Njikan Jet Dynamic Industry"
# }
module Handler::FSDJump
  def self.handle(event)
    e = Discordrb::Webhooks::Embed.new(
      description: "Jumped to **#{event['StarSystem']}**",
      color: 0x0000ff,
      timestamp: Time.parse(event['timestamp'])
    )

    e.add_field(
      name: 'System Info',
      inline: true,
      value: <<~info
        Controlling Faction: `#{event['Faction']}`
        Government: `#{event['Government_Localised']}`
        Allegiance: `#{event['Allegiance']}`
        Economy: `#{event['Economy_Localised']}`
        Security: `#{event['Security_Localised']}`
      info
    )

    e.add_field(
      name: 'Jump Info',
      inline: true,
      value: <<~info
        Distance: `#{event['JumpDist'].round(2)} ly`
        Fuel used: `#{event['FuelUsed'].round(2)}`
        Fuel level: `#{event['FuelLevel'].round(2)}`
      info
    )

    e.add_field(
      name: 'Powerplay',
      value: "#{event['Powers'].join(', ')} (#{event['PowerplayState']})"
    )

    e
  end
end

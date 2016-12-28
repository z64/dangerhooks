# Triggered when a player jumps to another system
# {
#   "timestamp": "2016-12-28T20:28:59Z",
#   "event": "FSDJump",
#   "StarSystem": "Sentec",
#   "StarPos": [
#     -34.406,
#     -120.781,
#     57.375
#   ],
#   "SystemAllegiance": "Independent",
#   "SystemEconomy": "$economy_Agri;",
#   "SystemEconomy_Localised": "Agriculture",
#   "SystemGovernment": "$government_Democracy;",
#   "SystemGovernment_Localised": "Democracy",
#   "SystemSecurity": "$SYSTEM_SECURITY_low;",
#   "SystemSecurity_Localised": "Low Security",
#   "Powers": [
#     "Archon Delaine"
#   ],
#   "PowerplayState": "Exploited",
#   "JumpDist": 17.107,
#   "FuelUsed": 0.729802,
#   "FuelLevel": 30.251379,
#   "SystemFaction": "Democrats of Sentec"
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
        Controlling Faction: `#{event['SystemFaction']}`
        Government: `#{event['SystemGovernment_Localised']}`
        Allegiance: `#{event['SystemAllegiance']}`
        Economy: `#{event['SystemEconomy_Localised']}`
        Security: `#{event['SystemSecurity_Localised']}`
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

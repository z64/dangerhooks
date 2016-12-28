# Triggered when a player redeems vouchers (bounty, conflict zone)
# {
#   "timestamp": "2016-10-30T11:11:16Z",
#   "event": "RedeemVoucher",
#   "Type": "bounty",
#   "Amount": 523937
# }
module Handler::RedeemVoucher
  def self.handle(event)
    event['Type'] = 'combat bond' if event['Type'] == 'CombatBond'

    Discordrb::Webhooks::Embed.new(
      description: "Redeemed `#{event['Amount']} CR` in #{event['Type']} vouchers!",
      color: 0x00ff00,
      timestamp: Time.parse(event['timestamp'])
    )
  end
end

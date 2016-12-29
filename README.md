# Dangerhooks

A client for sending in-game events from Elite: Dangerous to a Discord channel, or another source that can otherwise accept JSON payloads.

![preview](http://imgur.com/inntEpN.jpg)

## How to use

### Installation
1. [Install Ruby](https://www.ruby-lang.org) - be sure to click the option to 'associate \*.rb files with this installation of Ruby'
2. Open your CMD prompt and run `gem install bundler`
3. Download this repository with Git, or [as a ZIP file.](https://github.com/z64/dangerhooks/archive/master.zip)
4. Navigate to where you downloaded the code with `cd`
5. Run `bundle install` to install dependencies

### Configure
1. Use a text editor to place a webhook URL in place of '127.0.0.1' in the `config.yaml` file. If you don't know what this is, ask your server admin. You can also have multiple webhook URLs and your events will be 'syndicated' to all of them.
2. Double click `run.rb`
3. Play Elite

## Adding and removing events

The `config.yaml` follows a simple format for you to edit that specifies what events will be sent to the webhook. Note that not all events are supported, and there are some events you *shouldn't* send, as they are very common and might just be annoying, or may otherwise violate privacy (like `SendText` and `ReceiveText`). A recommended set of supported events is already provided in the default config file.

There are additional notes and instructions provided in the `config.yaml` file.

## Contributing

Check out the latest journal manual [found here](https://forums.frontier.co.uk/showthread.php/275151-Commanders-log-manual-and-data-sample).

Find out what events we don't have yet, and write a handler for them. Even if they are unlikely to be used or helpful, full support would be ideal as one may never know what another end-user may like.

A handler is just a module that responds to `#handle`, which takes the hash of the event to be handled. It should return a `Discordrb::Webhooks::Embed` that can be sent to the webhook clients.

Please include the sample payload that you used to build them embed with, along with a description of the event. You may also create any other helper methods to be used internally, called by `#handle` to help build the embed.

For documentation on how to write embeds, [see here](http://www.rubydoc.info/github/meew0/discordrb/Discordrb/Webhooks/Embed) and the related classes in the `Webhooks` family.

```ruby
# Triggered when a player undocks from a station
# { "timestamp":"2016-12-22T00:21:17Z", "event":"Undocked", "StationName":"Bohme's Folly" }
module Handler::Undocked
  def self.handle(event)
    Discordrb::Webhooks::Embed.new(
      description: "Undocked from #{event['StationName']}",
      timestamp: Time.now
    )
  end
end
```

## Support

Contact `Lune#2639` on Discord, or create an issue here on GitHub.

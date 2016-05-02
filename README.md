
# Encinch

Transparent blowfish encryption plugin for Cinch: An IRC Bot Building Framework

https://github.com/cinchrb/cinch


## Installation

  $[sudo] gem install encinch

## Example
  ```ruby
  require 'cinch'
  require 'cinch/plugins/encinch'


  bot = Cinch::Bot.new do
    configure do |c|
      c.nick            = "EnCinch"
      c.server          = "irc.freenode.org"
      c.port            = 7000
      c.ssl.use         = true
      c.channels        = ["#cryptedchan", "#plaintext", "#ignorechannel"]

      c.plugins.plugins = [Cinch::Plugins::EnCinch] # optionally add more plugins

      c.plugins.options[Cinch::Plugins::EnCinch] = {
        :drop       => true,
        :key_file   => 'keys/key.yml',
        :uncrypted  => ["#plaintext"],
        :ignore     => ["#ignorechan", "ignoreperson"],
        :encrypt    => {
          '#cryptedchan'  => 'myfishkey',
          '#ignorechan'   => 'ignoretargetscanhaveencryptionkeys'
          'cryptednick'   => 'mypersonalfishkey',
          :default        => 'defaultfishkey'
        }
      }
    end
  end

  bot.start
  ```

## Features
  - Simple transparent message encryption for your Cinch IRC bot.
  - Nicks with personal keys are updated on nick change.
  - Ignore incoming encrypted messages from specific channels or users.
  - Allow unencrypted messages to specific channels or users.
  - Drop messages if target key not found.
  - Ability to define default encryption key.
  - Keys and options stored in yaml.

## Commands
  None. You should write your own plugin to add or remove keys, tailored to your particular needs.


## Options
### :encrypt
A hash of encryption targets and their corresponding encryption keys. Targets should all be lowercase.
`:default` can provide a general purpose key, possibly good for private communications with the bot or ensuring it does not respond unencrypted.

### :uncrypted
An array of channels and individuals from which the bot will not encrypt messages. All entries must be lowercase.
`:uncrypted` is optional.

### :ignore
An array of channels and individuals (other bots?) to ignore encrypted messages. All entries must be lower case. Note that it will not drop messages sent from the bot.
`:ignore` is optional.

### :drop
Boolean value indicating if unencrypted messages should be dropped. Targets in the `:uncrypted` array are not affected. Unnecessary if a `:default` key is set.

### :key_file
Options are now stored in yaml. The default location is 'keys/encinch.yml'. Supply an alternate location if you so desire. Location will be created if it does not exist.

## TODO
  1. key exchange
  2. user feedback... :-)

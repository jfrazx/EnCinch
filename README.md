
# Encinch

Transparent blowfish encryption plugin for Cinch: An IRC Bot Building Framework

https://github.com/cinchrb/cinch


## Installation

  $[sudo] gem install encinch

## Example
  ```
  require 'cinch'
  require 'cinch/plugins/encinch'


  bot = Cinch::Bot.new do
    configure do |c|
      c.nick            = "EnCinch"
      c.server          = "irc.freenode.org"
      c.port            = 7000
      c.ssl.use         = true
      c.channels        = ["#cryptedchan", "#plaintext"]

      c.plugins.plugins = [Cinch::Plugins::EnCinch] # optionally add more plugins

      c.plugins.options[Cinch::Plugins::EnCinch] = {
        :ignore     => ["#ignorechannel", "ignoreperson"],
        :encrypt    => {
          '#cryptedchan'  => "myfishkey",
          'cryptednick'   => "mypersonalfishkey",
          :default        => "defaultfishkey"
        },
        :uncrypted  => ["#plaintext"]
      }
    end
  end

  bot.start
  ```

## Commands
  None, yet. 


## Options
### :encrypt
A hash of encryption targets and their corresponding encryption keys. Targets should all be lowercase.
:default can provide a general purpose key, generally good for private communications with the bot.
The :encrypt option must be set, :default is optional.

### :uncrypted
An array of channels and individuals from which the bot will not encrypt messages. All entries must be lowercase. This option must be set. If there are no desired unencrypted targets set an empty array.

### :ignore
An array of channels and individuals (other bots?) to ignore encrypted messages. All entries must be lower case.
:ignore is optional.

## TODO
  1. keyexchange
  2. maybe store keys to a file?
  3. add commands for updating, removing and adding keys and other settings?
  4. user feedback... :-)

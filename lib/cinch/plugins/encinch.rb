require 'cinch'
require "crypt/blowfish"
require_relative "encinch/encryption"
require_relative "encinch/capture"
require_relative "encinch/extend"


bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "EnCinch"
    c.realname        = "EnCinch"
    c.server          = "irc.freenode.org"
    c.port            = 7000
    c.verbose         = true
    c.ssl.use         = true
    c.plugins.plugins = [Cinch::Plugins::EnCinch]
    c.plugins.options[Cinch::Plugins::EnCinch] = {
      :ignore  => ["#ignorechannel", "ignoreperson"],
      :encrypt => {
        '#kwirk'  => "myfishkey",
        'iamayam' => "notmyfishkey",
        :default  => "adefaultfishkey"
      },
      :uncrypted  => ["#plaintext"]
    }
    c.channels        = ["#kwirk"]
  end
end

bot.start

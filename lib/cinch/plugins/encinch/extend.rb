
module Cinch
  module Exceptions

    # error to raise for missing required plugin options
    class MissingRequiredPluginOptions < Generic
    end
  end


  class IRC

    # Send a message to the server.
    # @param [String] msg
    # @return [void]
    def send(msg)

      # TODO match and modify ACTION
      if msg.match(/(PRIVMSG|NOTICE)/) && !msg.match(/\+OK (\S+)/)

        verb, target, *message = msg.split
        message = message.join(' ')[1..-1] rescue nil

        # retrieve bot options
        if (message && !message.empty?) && options = @bot.config.plugins.options[Cinch::Plugins::EnCinch]

          # key exists
          if key = (options[:encrypt][target.downcase] || options[:encrypt][:default])

            # ignore if target is in the 'uncrypted' array
            unless options[:uncrypted].include?(target.downcase)

              fish = Cinch::Plugins::EnCinch::Encryption.new(key)
              encrypted = fish.encrypt(message)
              msg.sub!(message, encrypted)
            end
          end
        end
      end   

      @queue.queue(msg)
    end

    private

  end
end

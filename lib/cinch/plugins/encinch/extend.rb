
module Cinch
  class IRC

    # alias instead of modify directly
    alias :encinch_send :send

    # Send a message to the server.
    # @param [String] msg
    # @return [void]
    def send(msg)
      if msg.match(/(PRIVMSG|NOTICE)/) && !msg.match(/\+OK (\S+)/)
        _, _, target, message = *msg.match(/(\S+) (\S+) :(.*)/m)
        target.downcase!

        unless message.empty?
          # retrieve bot options
          options = @bot.config.shared[:encinch].storage.data

          # ignore if target is in the 'uncrypted' array
          unless options[:uncrypted].include?(target)

            # match ctcp? and action messages
            if matched = message.match(/\001ACTION\s(.+)\001/)
              message = matched[-1]
            elsif message =~ /\001.+\001/
              return encinch_send(msg)
            end

            # key exists
            if key = (options[:encrypt][target] || options[:encrypt][:default])

              encrypted = Cinch::Plugins::EnCinch::Encryption.new(key).encrypt(message)
              msg.sub!(message, encrypted)

            else
              return if options[:drop]
            end
          end
        end
      end

      encinch_send(msg)
    end
  end
end

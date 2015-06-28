
module Cinch
  module Plugins
      class EnCinch
        include Cinch::Plugin

        def initialize(*)
          super

          # does Cinch have something to checked required options already???
          raise MissingRequiredPluginOptions unless config[:encrypt]
          raise MissingRequiredPluginOptions unless config[:uncrypted]

        end

        #
        # All blowfish communication should be prefixed with +OK
        # capture this to start the process
        #

        match(/\+OK (\S+)/, use_prefix: false, strip_colors: true, method: :capture)

        def capture(m, message)
          target = (m.channel ? m.channel.name : m.user.nick).downcase
          message = strip(m, message)

          return if config[:ignore].include?(target) rescue nil
          @key = config[:encrypt][target] || config[:encrypt][:default] rescue nil

          return unless @key

          blowfish(@key)

          decrypted = decrypt(message)
          decrypted << '\u0001' if m.action?

          raw = modify_raw(m.raw, decrypted)

          dispatch(Message.new(raw, m.bot))
        end

        #
        # matching for key exchange
        # NOT WORKING YET
        # It appears Cinch does not emit a :notice event, unfortunate
        #

        match(/DH1080_INIT/, use_prefix: false, react_on: [:private, :notice], method: :key_exchange)

        def key_exchange(m)
          return if m.channel?

          debug "captured key exchange event with key: #{m.message}"

          #TODO -- everything
        end

        # not sure this is actually needed
        def encrypt(message)
          @fish.encrypt(message)
        end

        def decrypt(message)
          @fish.decrypt(message)
        end

        def blowfish(key)
          @fish = Cinch::Plugins::EnCinch::Encryption.new(key)
        end

        private

        def dispatch(msg)
          events = [[:catchall]]

          if ["PRIVMSG", "NOTICE"].include?(msg.command)
            events << [:ctcp] if msg.ctcp?

            if msg.channel?
              events << [:channel]
            else
              events << [:private]
            end

            if msg.command == "PRIVMSG"
              events << [:message]
            else 
              events << [:notice]
            end

            if msg.action?
              events << [:action]
            end
          end

          meth = "on_#{msg.command.downcase}"
          __send__(meth, msg, events) if respond_to?(meth, true)

          if msg.error?
            events << [:error]
          end

          events << [msg.command.downcase.to_sym]

          msg.events = events

          #if its still encrypted for whatever reason we will not be processing it again
          msg.events.each do |event, *args|
            msg.bot.handlers.dispatch(event, msg, *args)
          end unless encrypted?(msg.raw) 
        end

        # 
        # TODO: strip ctcp? others?
        #

        def strip(m, data)
          data.sub!(/\u0001$/, '') if m.action?

          data
        end

        def encrypted?(data)
          !!data.match(/\+OK \S+/)
        end

        #
        # replace the encrypted message with the decrypted
        #

        def modify_raw(data, decrypted)
          data.sub!(/\+OK \S+(\s+)?(\S+)?/, decrypted)
          data
        end
      end
  end
end


module Cinch
  module Plugins
    class EnCinch
      include Cinch::Plugin

      def initialize(*)
        super
        config[:uncrypted] ||= Array.new
        config[:ignore]    ||= Array.new
        config[:encrypt]   ||= Hash.new

        shared[:encinch] = EnCinch::Storage.new(bot, config.dup)
      end

      #
      # All blowfish communication should be prefixed with +OK
      # capture this to start the process
      #

      match(/\+OK (\S+)/, use_prefix: false, strip_colors: true, method: :capture)
      def capture(m, message)
        target = (m.channel? ? m.channel.name : m.user.nick).downcase

        options = shared[:encinch].storage.data

        return if options[:ignore].include?(target)
        return unless key = options[:encrypt][target] || options[:encrypt][:default]

        blowfish(key)

        message = strip(message)
        decrypted = decrypt(message)

        @fish = nil

        decrypted << '\u0001' if m.action?
        raw = modify_raw(m.raw, decrypted)

        dispatch(Message.new(raw, m.bot))
      end

      #
      # matching for key exchange
      # NOT WORKING YET
      #
      # DH1080_INIT U5bsJHJUvzIeflIxOvz+wht3LojOx8JEz83wa5ByfN9yQlT2AlW6fjp277w4TmElwwLzOxhBA/W/7kwW5FJ4MxmZuxT9q2caMS2jbGXKpW5P6UcIQ7fg2yLqyl8KgU4X5JnC61zeoF5QwyemXdegstq90V6Cn3MqRPeeN2A7HCOeU0O52YD4A
      match(/DH1080_INIT (\S+)\s*(cbc|CBC)?/, use_prefix: false, react_on: :notice, method: :key_exchange)
      def key_exchange(m, key, cbc = false)
        return if m.channel?

        debug "captured key exchange event with key: #{m.message}"

        #TODO -- everything
      end

      def encrypt(message)
        @fish.encrypt(message)
      end

      def decrypt(message)
        @fish.decrypt(message)
      end

      def blowfish(key)
        @fish = Encryption.new(key)
      end

      def encrypted?(data)
        !!data.match(/\+OK \S+/)
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
          end

          if msg.action?
            events << [:action]
          end
        end

        meth = "on_#{msg.command.downcase}"
        __send__(meth, msg, events) if respond_to?(meth, true)

        events << [:error] if msg.error?

        events << [msg.command.downcase.intern]

        msg.events = events

        #if its still encrypted for whatever reason we will not be processing it again
        msg.events.each do |event, *args|
          msg.bot.handlers.dispatch(event, msg, *args)
        end unless encrypted?(msg.raw)
      end

      def strip(data)
        data.sub(/\u0001$/, '')
      end

      #
      # replace the encrypted message with the decrypted
      #

      def modify_raw(data, decrypted)
        data.sub(/\+OK \S+(\s+\S+)?/, decrypted)
      end
    end
  end
end

module Cinch
  module Plugins
    class EnCinch
      class Storage
        include Cinch::Plugin

        attr_reader :storage

        def initialize(bot, data)
          super(bot)

          file = data.delete(:key_file) || 'keys/encinch.yml'
          make_dirp(file)

          @storage = ::Cinch::Storage.new(file, data)

          @storage.data.merge!(data) do |key, x, y|
            case x
            when Hash
              x.merge!(y || {})
            when Array
              x.concat(y || []).uniq
            when NilClass
              y
            else
              if y.nil? || y.empty?
                x
              else
                y
              end
            end
          end

          @storage.data[:drop] ||= false

          save
        end

        # listen to nick change and update

        listen_to :nick
        def listen(m)
          if @storage.data[:encrypt][m.user.last_nick.downcase]
            @storage.data[:encrypt][m.user.nick.downcase] = @storage.data[:encrypt].delete(m.user.last_nick.downcase)
            save
          end
        end

        #
        # save keys in yaml
        #
        def save
          synchronize(:encinch_storage_save) do
            @storage.save
          end
        end

        def make_dirp(file)
          path = File.expand_path(File.dirname(file))
          FileUtils.mkdir_p(path) unless Dir.exist?(path)
        end
        private :make_dirp
      end
    end
  end
end

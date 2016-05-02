module Cinch
  module Plugins
    class EnCinch

      def config
        @bot.options[self.class]
      end
    end
  end

  class Message
    def privmsg_channel_name(s)
      nil
    end
  end
end

class EnCinchTest < TestCase
  parallelize_me!

  def setup
    bot = Bot.new
    bot.options[Cinch::Plugins::EnCinch] = { encrypt: Hash.new }
    @encinch = Cinch::Plugins::EnCinch.new(bot)
    @message = ":encrypt_me!~encrypt_me@192.168.1.1 PRIVMSG #encinch :hello"
    @encrypted_message = ":encrypt_me!~encrypt_me@192.168.1.1 PRIVMSG #encinch :+OK 3hcMC.j7WrK."
    @key = "thisisafishkey"
  end

  def test_plugin_options_retrieval
    assert_equal @encinch.shared[:encinch].storage.data, { ignore: [], uncrypted:[], encrypt: {}, drop: false }
  end

  def test_encrypt_message
    encrypted = @encinch.blowfish(@key).encrypt(@message)
    assert_equal false, @encinch.encrypted?(@message)
    assert_equal true, @encinch.encrypted?(encrypted)
  end

  def test_decrypt_message
    encrypted = @encinch.blowfish(@key).encrypt(@message)
    assert_equal false, @encinch.encrypted?(@message)
    assert_equal true, @encinch.encrypted?(encrypted)

    decrypted = @encinch.decrypt(encrypted)

    assert_equal @message, decrypted
  end

  def test_add_user_to_ignore
    @encinch.shared[:encinch].storage.data[:ignore] << "ignore_me"
    assert_equal ["ignore_me"], @encinch.shared[:encinch].storage.data[:ignore]
  end

  def test_add_user_to_uncrypted
    @encinch.shared[:encinch].storage.data[:uncrypted] << "plain_text"
    assert_equal ["plain_text"], @encinch.shared[:encinch].storage.data[:uncrypted]
  end

  def test_add_user_to_encrypted
    @encinch.shared[:encinch].storage.data[:encrypt]["encrypt_me"] = "myencryptionkey"
    expected = { "encrypt_me" => "myencryptionkey" }
    assert_equal expected, @encinch.shared[:encinch].storage.data[:encrypt]
  end

  def test_capture_ignore_user
    @encinch.shared[:encinch].storage.data[:ignore] << ignore = "ignore_me"
    encrypted_message = ":encrypt_me!~encrypt_me@192.168.1.1 PRIVMSG ignore_me :+OK 3hcMC.j7WrK."

    user = Cinch::User.new(ignore, @encinch.bot)
    @encinch.bot.ulist << user

    message = Cinch::Message.new(encrypted_message, @encinch.bot)

    result = @encinch.capture(message, message.message)

    assert_nil result
  end

  def test_capture_no_key
    encrypted_message = ":encrypt_me!~encrypt_me@192.168.1.1 PRIVMSG no_key :+OK 3hcMC.j7WrK."
    user = Cinch::User.new("no_key", @encinch.bot)
    @encinch.bot.ulist << user
    message = Cinch::Message.new(encrypted_message, @encinch.bot)
    result = @encinch.capture(message, message.message)

    assert_nil result
  end

  def test_capture_user_encrypted_message
    @encinch.shared[:encinch].storage.data[:encrypt]["encrypt_me"] = @key
    user = Cinch::User.new("encrypt_me", @encinch.bot)
    @encinch.bot.ulist << user

    message = Cinch::Message.new(@encrypted_message, @encinch.bot)

    @encinch.capture(message, message.message)
    assert_equal "hello", @encinch.bot.message.message
  end
end

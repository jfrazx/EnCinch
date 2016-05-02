module Cinch
  class IRC
    attr_reader :message
    def encinch_send(msg)
      @message = msg
    end
  end
end

class ExtendTest < TestCase
  parallelize_me!

  def setup
    bot = Bot.new
    bot.options[Cinch::Plugins::EnCinch] = { encrypt: Hash.new }
    @irc = Cinch::IRC.new(bot)
    @encinch = Cinch::Plugins::EnCinch.new(bot)
    @message = "hello"
    @channel = "PRIVMSG #encinch :"
    @user = "PRIVMSG encinch :"
    @key = "thisisafishkey"
    @encrypted = @encinch.blowfish(@key).encrypt(@message)
    @lines = ["Lorem ipsum dolor sit amet", "dicat admodum est cu", "ne ferri soleat dolorum usu.", "Mel cu aliquid docendi temporibus", "at pri odio congue interesset. Quot assentior vis te", "ius ad wisi placerat deserunt", "facete insolens pri ex. An duo tantas veritus. Augue commodo sed ei", "ius quod eruditi lobortis id", "ne epicurei consetetur vim. Quo no debitis electram deseruisse", "quis senserit ei vis."]
  end

  def test_send_encrypted_message_pass_through
    @irc.send(@channel + @encrypted)
    assert_equal @channel + @encrypted, @irc.message
  end

  def test_send_uncrypted_message_encrypt
    @encinch.shared[:encinch].storage.data[:encrypt]["#encinch"] = @key
    @irc.send(@channel + @message)
    assert_equal @channel + @encrypted, @irc.message
  end

  def test_send_larger_chunks
    @encinch.shared[:encinch].storage.data[:encrypt]["#encinch"] = @key
    @lines.each do |line|
      @irc.send(@channel + line)
      crypted = @encinch.blowfish(@key).encrypt(line)
      assert_equal @channel + crypted, @irc.message
    end
  end

  def test_send_default_key
    default = "thisisdefaultkey"
    @encinch.shared[:encinch].storage.data[:encrypt][:default] = default

    @lines.each do |line|
      @irc.send(@channel + line)
      crypted = @encinch.blowfish(default).encrypt(line)
      assert_equal @channel + crypted, @irc.message
    end
  end

  def test_send_uncrypted_message_bypass
    @encinch.shared[:encinch].storage.data[:uncrypted] << '#encinch'
    @irc.send(@channel + @message)
    assert_equal @channel + @message, @irc.message
  end

  def test_send_user_default_key
    default = "thisisdefaultkey"
    @encinch.shared[:encinch].storage.data[:encrypt][:default] = default

    @lines.each do |line|
      @irc.send(@user + line)
      crypted = @encinch.blowfish(default).encrypt(line)
      assert_equal @user + crypted, @irc.message
    end
  end

  def test_send_text_with_newline_character
    string = "this is some text with \n a new line character"
    @encinch.shared[:encinch].storage.data[:encrypt]["encinch"] = @key
    @irc.send(@user + string)

    crypted = @encinch.blowfish(@key).encrypt(string)

    assert_equal @user + crypted, @irc.message
  end

  def test_send_text_with_return_character
    string = "this is some text with \r a return character"
    @encinch.shared[:encinch].storage.data[:encrypt]["encinch"] = @key
    @irc.send(@user + string)

    crypted = @encinch.blowfish(@key).encrypt(string)

    assert_equal @user + crypted, @irc.message
  end

  def test_send_text_with_tab_character
    string = "this is some text with \t a tab character"
    @encinch.shared[:encinch].storage.data[:encrypt]["encinch"] = @key
    @irc.send(@user + string)

    crypted = @encinch.blowfish(@key).encrypt(string)

    assert_equal @user + crypted, @irc.message
  end

  def test_send_text_with_newline_return_tab_characters
    string = "this is some text with \t a tab character and a \r return character, and a \n newline character"
    @encinch.shared[:encinch].storage.data[:encrypt]["encinch"] = @key
    @irc.send(@user + string)

    crypted = @encinch.blowfish(@key).encrypt(string)

    assert_equal @user + crypted, @irc.message
  end

  def test_send_action_message
    string = "this is some action text"
    @encinch.shared[:encinch].storage.data[:encrypt]["encinch"] = @key
    @irc.send("#{ @user }\u0001ACTION #{ string }\u0001")
    crypted = @encinch.blowfish(@key).encrypt(string)

    assert_equal "#{ @user }\u0001ACTION #{ crypted }\u0001", @irc.message
  end

  def test_send_finger_pass_through
    @encinch.shared[:encinch].storage.data[:encrypt]["encinch"] = @key
    @irc.send("#{ @user }\u0001FINGER\u0001")

    assert_equal "#{ @user }\u0001FINGER\u0001", @irc.message
  end

  def test_send_empty_message
    @encinch.shared[:encinch].storage.data[:encrypt]["encinch"] = @key
    @irc.send(@user + String.new)

    assert_equal @user + String.new, @irc.message
  end

  def test_send_long_empty_message
    string = "         "
    @encinch.shared[:encinch].storage.data[:encrypt]["encinch"] = @key
    @irc.send(@user + string)
    crypted = @encinch.blowfish(@key).encrypt(string)

    assert_equal @user + crypted, @irc.message
  end

  def test_send_drop_channel_message
    @encinch.shared[:encinch].storage.data[:drop] = true
    @irc.send(@channel + @message)
    assert_nil @irc.message
  end

  def test_send_drop_user_message
    @encinch.shared[:encinch].storage.data[:drop] = true
    @irc.send(@user + @message)
    assert_nil @irc.message
  end

  def test_send_allow_uncrypted_channel_no_drop
    @encinch.shared[:encinch].storage.data[:drop] = true
    @encinch.shared[:encinch].storage.data[:uncrypted] << '#encinch'
    @irc.send(@channel + @message)
    assert_equal @channel + @message, @irc.message
  end

  def test_send_allow_uncrypted_user_no_drop
    @encinch.shared[:encinch].storage.data[:drop] = true
    @encinch.shared[:encinch].storage.data[:uncrypted] << 'encinch'
    @irc.send(@user + @message)
    assert_equal @user + @message, @irc.message
  end
end

class StorageTest < TestCase
  def setup
    bot = Bot.new
    @options = {
      ignore: Array.new,
      uncrypted: Array.new,
      encrypt: Hash.new
    }

    @storage = Cinch::Plugins::EnCinch::Storage.new(bot, @options)
  end

  def test_retrieve_options
    @options[:drop] = false
    assert_equal @options, options
  end

  def test_add_ignore_options
    opts = options[:ignore]
    assert_equal @options[:ignore], opts

    opts << 'ignore_me'

    assert_equal opts, options[:ignore]
  end

  def test_add_uncrypted_options
    opts = options[:uncrypted]
    assert_equal @options[:uncrypted], opts

    opts << 'uncrypt_me'

    assert_equal opts, options[:uncrypted]
  end

  def test_add_encryption_target
    opts = options[:encrypt]

    assert_equal @options[:encrypt], opts

    opts[:default] = 'thisisafishkey'

    assert_equal options[:encrypt], opts
  end

  def test_save_storage
    assert_instance_of File, @storage.save
  end

  def options
    @storage.storage.data
  end
  private :options
end

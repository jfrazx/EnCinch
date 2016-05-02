require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../lib/cinch/plugins/encinch'

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

if ENV["SIMPLECOV"]
  begin
    require 'simplecov'
    SimpleCov.start
  rescue LoadError
  end
end

unless Object.const_defined? 'Cinch'
  $:.unshift File.expand_path('../../lib', __FILE__)
  require 'cinch'
end


class TestCase < MiniTest::Test
  def self.test(name, &block)
    define_method("test_" + name, &block) if block
  end
end

class Bot
  attr_accessor :ulist
  attr_reader :message, :event

  @@defined = false

  def initialize(*)
    @opts = Hash.new
    @ulist = Array.new
    @share = Hash.new
    method_maker unless @@defined
  end

  def method_maker
    [
      :config, :plugins, :loggers, :handlers, :debug, :register,
      :warn, :prefix, :suffix,:irc, :network, :user_list
    ].each do |method|
      self.class.send :define_method, method do |*|
        self
      end
    end

    @@defined = true
  end

  def isupport(*)
    []
  end

  def find_ensured(*)
    @ulist.first
  end
  private :method_maker

  def options
    @opts
  end

  def synchronize(name, &block)
    yield block if block_given?
  end

  def shared
    @share
  end

  def ngametv?
    false
  end

  def dispatch(event, message, *args)
    @event = event
    @message = message
  end
end

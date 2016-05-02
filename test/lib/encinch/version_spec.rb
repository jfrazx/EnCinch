class VersionTest < TestCase
  parallelize_me!

  def test_version_should_be_a_string
    assert_instance_of String, ::Cinch::Plugins::EnCinch::VERSION
  end

  def test_version_string_should_be_series_of_integers
    refute_empty ::Cinch::Plugins::EnCinch::VERSION.scan(/\d+/).map(&:to_i)
  end
end

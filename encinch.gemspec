# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch/plugins/encinch/version'

Gem::Specification.new do |spec|
  spec.name          = "encinch"
  spec.version       = EnCinch::Version::VERSION
  spec.authors       = ["jfrazx"]
  spec.email         = ["staringblind@gmail.com"]
  spec.summary       = %q{Transparent blowfish encryption plugin for Cinch: An IRC Bot Building Framework}
  spec.description   = %q{}
  spec.platform      = Gem::Platform::RUBY
  spec.homepage      = "https://github.com/jfrazx/EnCinch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "cinch", "~> 2.0"
  spec.add_runtime_dependency "crypt", "~> 2.0"
end

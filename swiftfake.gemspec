# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swiftfake/version'

Gem::Specification.new do |spec|
  spec.name          = "swiftfake"
  spec.version       = Swiftfake::VERSION
  spec.authors       = ["odlp"]

  spec.summary       = "Generate test fakes from Swift code."
  spec.homepage      = "https://github.com/odlp/swiftfake"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = ["swiftfake"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.1.0'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end

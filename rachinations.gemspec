# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rachinations/version'

Gem::Specification.new do |spec|
  spec.name          = "rachinations"
  spec.version       = Rachinations::VERSION
  spec.authors       = ["Felipe Almeida"]
  spec.email         = ["falmeida1988@gmail.com"]
  spec.summary       = %q{Ruby port for Dr. J. Dormans' Machinations Game Mechanics Diagrams.}
  spec.description   = %q{This project provides a Ruby-based Diagram to enable game designers to
design and also test tentative game designs and/or prototypes}
  spec.homepage      = "https://github.com/queirozfcom/rachinations"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(testing|spec|features|simulations)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.1'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec","~> 3.0"
  spec.add_development_dependency "minitest", "~> 5.4"
  spec.add_development_dependency "minitest-reporters", "~> 1.0"
  spec.add_development_dependency "coveralls", "0.7.0"

  spec.add_dependency "activesupport","3.0.0"
  spec.add_dependency "i18n","0.6.11"
  spec.add_dependency "weighted_distribution", "1.0.0"
  spec.add_dependency 'fraction','0.3.2'

end
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clone_util/version'

Gem::Specification.new do |spec|
  spec.name          = "clone_util"
  spec.version       = CloneUtil::VERSION
  spec.authors       = "Srijith C"
  spec.email         = "srijithc038@gmail.com"
  spec.summary       = "Copy the ActiveRecord objects recursively"
  spec.description   = "This gem helps us to copy the ActiveRecord objects recursively"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end

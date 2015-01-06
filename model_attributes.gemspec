# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'model_attributes/version'

Gem::Specification.new do |spec|
  spec.name          = "model_attributes"
  spec.version       = ModelAttributes::VERSION
  spec.authors       = ["David Waller"]
  spec.email         = ["dwaller@yammer-inc.com"]
  spec.summary       = %q{Attributes for non-ActiveRecord models}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",         "~> 1.7"
  spec.add_development_dependency 'bundler-yammer_gem_tasks'
  spec.add_development_dependency "rake",            "~> 10.0"
  spec.add_development_dependency "rspec",           "~> 3.1"
  spec.add_development_dependency "rspec-nc",        "~> 0.2"
  spec.add_development_dependency "guard",           "~> 2.8"
  spec.add_development_dependency "guard-rspec",     "~> 4.3"
  spec.add_development_dependency "pry-debugger"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wiser_trails/version'

Gem::Specification.new do |spec|
  spec.name          = "wiser_trails"
  spec.version       = WiserTrails::VERSION
  spec.authors       = ["Kenneth John Balgos"]
  spec.email         = ["kennethjohnbalgos@gmail.com"]
  spec.description   = "Audit Trails in Harmony"
  spec.summary       = ""
  spec.homepage      = "https://github.com/kennethjohnbalgos/wiser_trails"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'actionpack', '>= 3.0.0'
  spec.add_dependency 'railties', '>= 3.0.0'
  spec.add_dependency 'activerecord', '>= 3.0'
end

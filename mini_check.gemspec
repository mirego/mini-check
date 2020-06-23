# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mini_check/version'

Gem::Specification.new do |spec|
  spec.name          = 'mini_check'
  spec.version       = MiniCheck::VERSION
  spec.authors       = ['Manuel Morales']
  spec.email         = ['manuelmorales@gmail.com']
  spec.description   = %q{MiniCheck provides a simple Rack application for adding simple health checks to your app.}
  spec.summary       = %q{MiniCheck provides a simple Rack application for adding simple health checks to your app.}
  spec.homepage      = 'https://github.com/workshare/mini-check'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_runtime_dependency 'json', '>= 1'
end

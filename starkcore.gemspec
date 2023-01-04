# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'starkinfra-core'
  s.version = '0.0.1'
  s.summary = 'Basic SDK functionalities for the starkbank and starkinfra SDKs'
  s.authors = 'starkinfra'
  s.homepage = 'https://github.com/starkinfra/core-ruby'
  s.files = Dir['lib/**/*.rb']
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.3'
  s.add_dependency('starkbank-ecdsa', '~> 2.0.0')
  s.add_development_dependency('minitest', '~> 5.14.1')
  s.add_development_dependency('rake', '~> 13.0')
  s.add_development_dependency('rubocop', '~> 0.81')
end

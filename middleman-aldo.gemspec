# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-aldo/version'

Gem::Specification.new do |spec|
  spec.name          = 'middleman-aldo'
  spec.version       = Middleman::Aldo::VERSION
  spec.authors       = ['Badi Labassi']
  spec.email         = ['blabassi@aldogroup.com']
  spec.summary       = 'A series of helpers for consistency among Aldo Group Creative Studio\'s middleman sites'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/aldogroup/middleman-aldo'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  # Middleman
  spec.add_dependency 'middleman',              '~> 3.4'
  spec.add_dependency 'middleman-imageoptim',   '~> 0.2.1'
  spec.add_dependency 'middleman-livereload',   '~> 3.4'
  spec.add_dependency 'middleman-autoprefixer', '~> 2.4'
  spec.add_dependency 'middleman-pry',          '~> 1.0'

  # Assets
  spec.add_dependency 'sass',           '~> 3.4'
  spec.add_dependency 'slim',           '~> 3.0'
  spec.add_dependency 'susy',           '~> 2.2'
  spec.add_dependency 'fastimage',      '~> 2.0'
  spec.add_dependency 'oj',             '~> 2.11'
  spec.add_dependency 'builder',        '~> 3.2'
  spec.add_dependency 'redcarpet',      '~> 3.2'
  # spec.add_dependency 'livingstyleguide', '~> 2.0'
  # Server
  spec.add_dependency 'curb',               '~> 0.9'
  spec.add_dependency 'rack_staging',       '~> 0.2'
  spec.add_dependency 'rack-contrib',       '~> 1.2'
  spec.add_dependency 'rack-protection',    '~> 2.0'
  spec.add_dependency 'rack-rewrite',       '~> 1.5'
  spec.add_dependency 'thin',               '~> 1.6'
  spec.add_dependency 'rack-ssl-enforcer',  '~> 0.2'
  spec.add_dependency 'better_errors',      '~> 2.1'
  spec.add_dependency 'binding_of_caller', '~> 0.7'
  spec.add_dependency 'ruby-prof',          '~> 0.16'

  # Development dependencies
  spec.add_development_dependency 'rspec',    '~> 3.2'
  spec.add_development_dependency 'bundler',  '~> 1.7'
  spec.add_development_dependency 'rake',     '~> 10.4'
end

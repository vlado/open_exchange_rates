# -*- encoding: utf-8 -*-
require File.expand_path('../lib/open_exchange_rates/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Vlado Cingel"]
  gem.email         = ["vladocingel@gmail.com"]
  gem.description   = %q{Ruby library for Open Exchange Rates API - free / open source hourly-updated currency data for everybody}
  gem.summary       = %q{Ruby library for Open Exchange Rates API}
  gem.homepage      = "https://github.com/vlado/open_exchange_rates"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "open_exchange_rates"
  gem.require_paths = ["lib"]
  gem.version       = OpenExchangeRates::VERSION
  gem.license       = "MIT"

  gem.add_dependency('yajl-ruby')

  gem.add_development_dependency('rr')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('dotenv')
  gem.add_development_dependency('test-unit')
end

# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack-chain/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nick Sieger"]
  gem.email         = ["nick@nicksieger.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack-chain"
  gem.require_paths = ["lib"]
  gem.version       = Rack::Chain::VERSION

  gem.add_runtime_dependency "rack", [">= 1.4.0"]
  gem.add_development_dependency "rspec", [">= 2.8.0"]
end

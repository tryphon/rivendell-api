# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rivendell/api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alban Peignier"]
  gem.email         = ["alban@tryphon.eu"]
  gem.description   = %q{Use the rdxport interface to retrieve Groups, create/edit/retrieve Carts and Cuts, import Cut sound.}
  gem.summary       = %q{Pilots Rivendell via http/xml API}
  gem.homepage      = "http://projects.tryphon.eu/rivendell-api"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rivendell-api"
  gem.require_paths = ["lib"]
  gem.version       = Rivendell::Api::VERSION

  gem.add_runtime_dependency 'httmultiparty'
  gem.add_runtime_dependency 'activesupport'
  gem.add_runtime_dependency 'null_logger'

  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "fakeweb"
end

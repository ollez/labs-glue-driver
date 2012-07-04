# -*- encoding: utf-8 -*-
require File.expand_path('../lib/glue/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Johannes Edelstam"]
  gem.email         = ["johannes@edelst.am"]
  gem.description   = %q{A driver for the DR Labs glue layer}
  gem.summary       = %q{A driver for the DR Labs glue layer}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "glue"
  gem.require_paths = ["lib"]
  gem.version       = Glue::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'vcr'
  gem.add_dependency 'activesupport'
end

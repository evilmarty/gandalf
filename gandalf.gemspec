# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gandalf/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Marty Zalega"]
  gem.email         = ["marty@zalega.me"]
  gem.description   = %q{Simply delegates authentication and authorization to your own implementation.}
  gem.summary       = %q{Manage user authentication and authorization.}
  gem.homepage      = "http://github.com/everydayhero/gandalf"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "gandalf"
  gem.require_paths = ["lib"]
  gem.version       = Gandalf::VERSION

  gem.add_dependency 'rails', '>= 3.0.0'
end

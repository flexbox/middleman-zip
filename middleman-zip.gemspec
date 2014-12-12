# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-zip/version'

Gem::Specification.new do |spec|
  spec.name          = 'middleman-zip'
  spec.version       = Middleman::Zip::VERSION
  spec.authors       = ['mattjorn']
  spec.email         = ['mattjorn@users.noreply.github.com']
  spec.summary       = %q{Middleman extension that zips directories.}
  spec.description   = %q{middleman-zip is an extension for Middleman static site generator that allows you to zip directories.}
  spec.homepage      = 'https://github.com/mattjorn/middleman-zip'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'middleman-core', '>= 3.3.7'
  spec.add_runtime_dependency 'rubyzip'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
